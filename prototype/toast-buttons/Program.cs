// Throwaway prototype for docs/spikes/toast-buttons.md (A-1).
// Shows Windows toasts with two buttons through the built-in WinRT API
// (Windows.UI.Notifications), without the Windows App SDK, from an unpackaged,
// unsigned WinForms app, and logs what Windows reports back.
using System.Runtime.InteropServices;
using Microsoft.Win32;
using Windows.Data.Xml.Dom;
using Windows.UI.Notifications;

namespace ToastSpike;

internal static class Program
{
    public const string Aumid = "MoveReminder.ToastSpike";

    [DllImport("shell32.dll", CharSet = CharSet.Unicode, PreserveSig = false)]
    private static extern void SetCurrentProcessExplicitAppUserModelID(string appId);

    [STAThread]
    private static void Main()
    {
        // An unpackaged app has no identity of its own: register an AppUserModelID
        // for the current user and claim it for this process.
        using (var key = Registry.CurrentUser.CreateSubKey($@"Software\Classes\AppUserModelId\{Aumid}"))
        {
            key.SetValue("DisplayName", "Toast Spike");
        }
        SetCurrentProcessExplicitAppUserModelID(Aumid);

        ApplicationConfiguration.Initialize();
        Application.Run(new SpikeContext());
    }
}

internal static class Log
{
    private static readonly object Gate = new();
    public static readonly string Path = System.IO.Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "ToastSpike", "spike.log");

    public static void Write(string line)
    {
        lock (Gate)
        {
            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(Path)!);
            File.AppendAllText(Path, $"{DateTimeOffset.Now:O} {line}{Environment.NewLine}");
        }
    }
}

internal sealed class SpikeContext : ApplicationContext
{
    private readonly NotifyIcon _tray;
    private readonly ToastNotifier _notifier;
    // Keep every shown toast alive, so its Activated event can still fire later
    // (for example from the notification center).
    private readonly List<ToastNotification> _alive = new();

    public SpikeContext()
    {
        Log.Write($"started aumid={Program.Aumid} os={Environment.OSVersion.Version} pid={Environment.ProcessId}");
        _notifier = ToastNotificationManager.CreateToastNotifier(Program.Aumid);
        Log.Write($"notifier setting={_notifier.Setting}");

        var menu = new ContextMenuStrip();
        menu.Items.Add("1. Доставка: 10 уведомлений", null, (_, _) => Delivery());
        menu.Items.Add("2. Баннеры: 5 по очереди", null, (_, _) => ShowBanner(1));
        menu.Items.Add("3. Центр уведомлений: 5", null, (_, _) => ActionCenter());
        menu.Items.Add("4. Не беспокоить: 1", null, (_, _) => DoNotDisturb());
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("Выход", null, (_, _) => Exit());

        _tray = new NotifyIcon
        {
            Icon = SystemIcons.Information,
            Text = "Toast Spike",
            ContextMenuStrip = menu,
            Visible = true,
        };
    }

    // Toasts 1 to 3 of each batch expect "snooze", 4 and 5 expect "dismiss".
    private static string Expected(int n) => n <= 3 ? "snooze" : "dismiss";
    private static string Label(string action) => action == "snooze" ? "«Отложить»" : "«Закрыть»";

    private void Delivery()
    {
        ToastNotificationManager.History.RemoveGroup("delivery", Program.Aumid);
        for (var i = 1; i <= 10; i++)
        {
            Show($"d{i}", "delivery", $"Доставка {i} из 10", "Ничего не нажимай");
        }
        Thread.Sleep(1000);
        var count = ToastNotificationManager.History.GetHistory(Program.Aumid).Count(t => t.Group == "delivery");
        Log.Write($"delivery-history count={count}");
        ToastNotificationManager.History.RemoveGroup("delivery", Program.Aumid);
    }

    private void ShowBanner(int n)
    {
        if (n > 5)
        {
            Log.Write("banners done");
            return;
        }
        var id = $"b{n}";
        Show(id, "banner", $"Баннер {n} из 5", $"Нажми {Label(Expected(n))} прямо на баннере",
            onActivated: () => Task.Delay(2000).ContinueWith(_ => ShowBanner(n + 1)));
    }

    private void ActionCenter()
    {
        for (var n = 1; n <= 5; n++)
        {
            Show($"a{n}", "center", $"Центр уведомлений {n} из 5",
                $"Дождись, пока баннер исчезнет, открой центр уведомлений (Win+N) и нажми там {Label(Expected(n))}");
        }
    }

    private void DoNotDisturb()
    {
        ToastNotificationManager.History.RemoveGroup("dnd", Program.Aumid);
        Show("n1", "dnd", "Не беспокоить", "Это уведомление показано при включённом «Не беспокоить»");
        Thread.Sleep(1000);
        var count = ToastNotificationManager.History.GetHistory(Program.Aumid).Count(t => t.Group == "dnd");
        Log.Write($"dnd-history count={count}");
    }

    private void Show(string id, string group, string title, string body, Action? onActivated = null)
    {
        var xml = new XmlDocument();
        xml.LoadXml(
            $"""
            <toast launch="id={id};action=body">
              <visual>
                <binding template="ToastGeneric">
                  <text>{title}</text>
                  <text>{body}</text>
                </binding>
              </visual>
              <actions>
                <action content="Отложить" arguments="id={id};action=snooze" activationType="foreground"/>
                <action content="Закрыть" arguments="id={id};action=dismiss" activationType="foreground"/>
              </actions>
            </toast>
            """);
        var toast = new ToastNotification(xml) { Tag = id, Group = group };
        toast.Activated += (_, args) =>
        {
            var a = args as ToastActivatedEventArgs;
            Log.Write($"activated {a?.Arguments ?? "(no arguments)"}");
            onActivated?.Invoke();
        };
        toast.Dismissed += (_, args) => Log.Write($"dismissed id={id} reason={args.Reason}");
        toast.Failed += (_, args) => Log.Write($"failed id={id} error=0x{args.ErrorCode.HResult:X8}");
        lock (_alive)
        {
            _alive.Add(toast);
        }
        _notifier.Show(toast);
        Log.Write($"shown id={id} group={group}");
    }

    private void Exit()
    {
        Log.Write("exit");
        _tray.Visible = false;
        ExitThread();
    }
}
