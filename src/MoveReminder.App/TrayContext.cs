using MoveReminder.App.Resources;
using MoveReminder.Core;

namespace MoveReminder.App;

/// <summary>The app's life in the tray: an icon with a menu, and no window of its own.</summary>
internal sealed class TrayContext : ApplicationContext
{
    private readonly ContextMenuStrip _menu;
    private readonly NotifyIcon _tray;

    public TrayContext()
    {
        _menu = new ContextMenuStrip();
        _menu.Items.Add(Strings.Exit, null, (_, _) => Exit());

        _tray = new NotifyIcon
        {
            Icon = SystemIcons.Application,
            Text = Product.Name,
            ContextMenuStrip = _menu,
            Visible = true,
        };
    }

    private void Exit()
    {
        _tray.Visible = false;
        ExitThread();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _tray.Dispose();
            _menu.Dispose();
        }
        base.Dispose(disposing);
    }
}
