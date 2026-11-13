# Draws the app's icon, src/MoveReminder.App/Resources/move-reminder.ico: a white
# arrow pointing up ("stand up") on a green rounded square. The project's own
# artwork under its MIT licence, drawn here from shapes; no third-party art.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/make-icon.ps1
#
# Run it only to change the icon, and commit the .ico it writes. Every size is
# drawn on its own grid, not scaled down from a big one, so the small ones stay
# sharp: 16, 20, 24 and 32 px are the tray at 100%, 125%, 150% and 200% scaling;
# 40, 48 and 64 px are Explorer's lists and tiles; 256 px its large icons. The
# frames up to 64 px are 32-bit bitmaps, the 256 px one is PNG, as Windows expects.
param(
    [string]$OutFile = (Join-Path $PSScriptRoot '..\src\MoveReminder.App\Resources\move-reminder.ico')
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$sizes = 16, 20, 24, 32, 40, 48, 64, 256
$green = [System.Drawing.Color]::FromArgb(255, 0x13, 0x8A, 0x63)
$white = [System.Drawing.Color]::White

function New-Frame([int]$s) {
    $bmp = New-Object System.Drawing.Bitmap($s, $s, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $k = $s / 16.0

    # The rounded square fills the frame: a tray icon has no room to spare.
    $r = 3.5 * $k * 2
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0, 0, $r, $r, 180, 90)
    $path.AddArc($s - $r, 0, $r, $r, 270, 90)
    $path.AddArc($s - $r, $s - $r, $r, $r, 0, 90)
    $path.AddArc(0, $s - $r, $r, $r, 90, 90)
    $path.CloseFigure()
    $brush = New-Object System.Drawing.SolidBrush($green)
    $g.FillPath($brush, $path)

    # The arrow, on a 16-unit grid: its head from y=2 to y=8.5, its shaft 4 units wide.
    # Below 256 px its corners snap to whole pixels, so the shaft's edges stay sharp.
    $snap = $s -lt 256
    $p = { param($x, $y)
        $px = $x * $k; $py = $y * $k
        if ($snap) { $px = [math]::Round($px); $py = [math]::Round($py) }
        New-Object System.Drawing.PointF([single]$px, [single]$py) }
    $arrow = [System.Drawing.PointF[]]@(
        (& $p 8 2), (& $p 14 8.5), (& $p 10 8.5), (& $p 10 14),
        (& $p 6 14), (& $p 6 8.5), (& $p 2 8.5)
    )
    $fg = New-Object System.Drawing.SolidBrush($white)
    $g.FillPolygon($fg, $arrow)

    $fg.Dispose(); $brush.Dispose(); $path.Dispose(); $g.Dispose()
    return $bmp
}

# A 32-bit DIB as an icon frame: the header with the height doubled, the pixels
# bottom-up, then the 1-bit AND mask (set where the pixel is fully transparent).
function Get-DibBytes([System.Drawing.Bitmap]$bmp) {
    $s = $bmp.Width
    $ms = New-Object System.IO.MemoryStream
    $w = New-Object System.IO.BinaryWriter($ms)
    $maskStride = [int]([math]::Ceiling($s / 32.0) * 4)
    $w.Write([int]40); $w.Write([int]$s); $w.Write([int]($s * 2))
    $w.Write([int16]1); $w.Write([int16]32); $w.Write([int]0)
    $w.Write([int]($s * $s * 4 + $maskStride * $s))
    $w.Write([int]0); $w.Write([int]0); $w.Write([int]0); $w.Write([int]0)
    $mask = New-Object byte[] ($maskStride * $s)
    for ($y = $s - 1; $y -ge 0; $y--) {
        $row = $s - 1 - $y
        for ($x = 0; $x -lt $s; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $w.Write([byte]$c.B); $w.Write([byte]$c.G); $w.Write([byte]$c.R); $w.Write([byte]$c.A)
            if ($c.A -eq 0) {
                $i = $row * $maskStride + [int][math]::Floor($x / 8)
                $mask[$i] = $mask[$i] -bor (0x80 -shr ($x % 8))
            }
        }
    }
    $w.Write($mask)
    $w.Flush()
    return , $ms.ToArray()
}

function Get-PngBytes([System.Drawing.Bitmap]$bmp) {
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    return , $ms.ToArray()
}

$images = @()
foreach ($s in $sizes) {
    $bmp = New-Frame $s
    if ($s -ge 256) { $images += , (Get-PngBytes $bmp) } else { $images += , (Get-DibBytes $bmp) }
    $bmp.Dispose()
}

$out = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter($out)
$w.Write([int16]0); $w.Write([int16]1); $w.Write([int16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $s = $sizes[$i]
    $dim = if ($s -ge 256) { 0 } else { $s }
    $w.Write([byte]$dim); $w.Write([byte]$dim); $w.Write([byte]0); $w.Write([byte]0)
    $w.Write([int16]1); $w.Write([int16]32)
    $w.Write([int]$images[$i].Length); $w.Write([int]$offset)
    $offset += $images[$i].Length
}
foreach ($img in $images) { $w.Write($img) }
$w.Flush()
$full = [System.IO.Path]::GetFullPath($OutFile)
[System.IO.File]::WriteAllBytes($full, $out.ToArray())
Write-Output "make-icon: wrote $full ($($out.Length) bytes, sizes $($sizes -join ', '))"
