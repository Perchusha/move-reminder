namespace MoveReminder.App;

/// <summary>The app's own icon, Resources/move-reminder.ico, embedded in the assembly.</summary>
internal static class AppIcon
{
    internal const string ResourceName = "MoveReminder.App.Resources.move-reminder.ico";

    /// <summary>
    /// The icon at the tray's size: 16 px at 100% scaling up to 32 px at 200%.
    /// The .ico holds a frame for each, so none is scaled. The caller disposes it.
    /// </summary>
    internal static Icon ForTray()
    {
        using var stream = typeof(AppIcon).Assembly.GetManifestResourceStream(ResourceName)
            ?? throw new InvalidOperationException($"The resource {ResourceName} is missing from the app.");
        return new Icon(stream, SystemInformation.SmallIconSize);
    }
}
