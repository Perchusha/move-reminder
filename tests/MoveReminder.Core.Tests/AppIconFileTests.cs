namespace MoveReminder.Core.Tests;

// QA-E0-1: the app's own icon, src/MoveReminder.App/Resources/move-reminder.ico, holds a
// 32-bit frame for each size Windows asks for: the tray at 100% to 200% scaling (16, 20,
// 24, 32 px) and Explorer (40, 48, 64, 256 px). It reads the file only, with no Windows UI.
public sealed class AppIconFileTests
{
    private static readonly int[] Sizes = [16, 20, 24, 32, 40, 48, 64, 256];

    private static byte[] IconFile() =>
        File.ReadAllBytes(Path.Combine(AppContext.BaseDirectory, "move-reminder.ico"));

    private static List<(int Width, int Height, int BitCount, int Length, int Offset)> Frames(byte[] ico)
    {
        Assert.True(ico.Length > 6, "The .ico is too short for its header.");
        Assert.Equal(0, BitConverter.ToUInt16(ico, 0));
        Assert.Equal(1, BitConverter.ToUInt16(ico, 2));
        var count = BitConverter.ToUInt16(ico, 4);
        var frames = new List<(int, int, int, int, int)>();
        for (var i = 0; i < count; i++)
        {
            var at = 6 + (16 * i);
            var width = ico[at] == 0 ? 256 : ico[at];
            var height = ico[at + 1] == 0 ? 256 : ico[at + 1];
            frames.Add((width, height, BitConverter.ToUInt16(ico, at + 6), BitConverter.ToInt32(ico, at + 8), BitConverter.ToInt32(ico, at + 12)));
        }
        return frames;
    }

    [Fact]
    public void IconHasAFrameForEveryTrayAndExplorerSize()
    {
        var frames = Frames(IconFile());

        Assert.Equal(Sizes, frames.Select(f => f.Width).Order());
        Assert.All(frames, f => Assert.Equal(f.Width, f.Height));
    }

    [Fact]
    public void EveryFrameIs32BitWithItsDataInsideTheFile()
    {
        var ico = IconFile();

        Assert.All(Frames(ico), f =>
        {
            Assert.Equal(32, f.BitCount);
            Assert.InRange(f.Offset + (long)f.Length, 0, ico.Length);
            var png = f.Length > 8 && ico[f.Offset] == 0x89 && ico[f.Offset + 1] == (byte)'P';
            // Up to 64 px a bitmap, which every Windows tray reads; 256 px a PNG, as Explorer expects.
            Assert.Equal(f.Width == 256, png);
            if (!png)
            {
                Assert.Equal(40, BitConverter.ToInt32(ico, f.Offset));
                Assert.Equal(f.Width, BitConverter.ToInt32(ico, f.Offset + 4));
                Assert.Equal(32, BitConverter.ToUInt16(ico, f.Offset + 14));
            }
        });
    }

    [Fact]
    public void IconIsNotBlank()
    {
        // The 16 px frame, the tray at 100%: it has both opaque pixels and more than one colour.
        var ico = IconFile();
        var frame = Frames(ico).Single(f => f.Width == 16);
        var pixels = ico.AsSpan(frame.Offset + 40, 16 * 16 * 4).ToArray().Chunk(4).ToList();

        Assert.Contains(pixels, p => p[3] == 255);
        Assert.True(pixels.Where(p => p[3] == 255).Select(p => (p[0], p[1], p[2])).Distinct().Count() > 1);
    }
}
