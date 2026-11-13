using System.Reflection;
using System.Runtime.Versioning;

namespace MoveReminder.Core.Tests;

// E0-AC6: Core stays plain net10.0 and never depends on App, WinForms or WinRT.
public sealed class CoreBoundaryTests
{
    private static readonly Assembly Core = typeof(Product).Assembly;

    [Fact]
    public void CoreTargetsPlainNet10WithoutAPlatform()
    {
        var framework = Core.GetCustomAttribute<TargetFrameworkAttribute>();

        Assert.NotNull(framework);
        Assert.Equal(".NETCoreApp,Version=v10.0", framework.FrameworkName);
        Assert.Null(Core.GetCustomAttribute<TargetPlatformAttribute>());
        Assert.Null(Core.GetCustomAttribute<SupportedOSPlatformAttribute>());
    }

    [Theory]
    [InlineData("MoveReminder")]
    [InlineData("System.Windows.Forms")]
    [InlineData("System.Windows.Forms.Primitives")]
    [InlineData("Microsoft.Windows.SDK.NET")]
    [InlineData("WinRT.Runtime")]
    [InlineData("System.Net.Http")]
    [InlineData("System.Net.Sockets")]
    public void CoreDoesNotReference(string assembly)
    {
        var references = Core.GetReferencedAssemblies().Select(a => a.Name);

        Assert.DoesNotContain(assembly, references);
    }

    [Fact]
    public void ProductNameIsTheInstallAndSettingsFolderName()
    {
        Assert.Equal("move-reminder", Product.Name);
    }
}
