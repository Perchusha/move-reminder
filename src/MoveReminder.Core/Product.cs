namespace MoveReminder.Core;

/// <summary>Names the product uses wherever it shows up: the tray, the install folder, the settings folder.</summary>
public static class Product
{
    /// <summary>The product name, also the name of the install folder and of the settings folder (ADR-0001, ADR-0002).</summary>
    public const string Name = "move-reminder";
}
