namespace MoveReminder.App;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        using var tray = new TrayContext();
        Application.Run(tray);
    }
}
