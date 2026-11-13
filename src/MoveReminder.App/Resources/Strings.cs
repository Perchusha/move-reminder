using System.Globalization;
using System.Resources;

namespace MoveReminder.App.Resources;

/// <summary>The interface strings, read from Strings.resx (docs/STACK.md, i18n).</summary>
internal static class Strings
{
    private static readonly ResourceManager Manager = new("MoveReminder.App.Resources.Strings", typeof(Strings).Assembly);

    /// <summary>The tray menu item that closes the app.</summary>
    public static string Exit => Get(nameof(Exit));

    private static string Get(string name) =>
        Manager.GetString(name, CultureInfo.CurrentUICulture)
        ?? throw new MissingManifestResourceException($"The string {name} is missing from Strings.resx.");
}
