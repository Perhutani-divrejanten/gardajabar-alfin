# Script untuk mengganti gambar brand lama dengan logo teks Garda Jabar di semua HTML files

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Garda Jabar"
$legacyLogoFile = 'logo' + '.png'
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File

$textBasedLogo = @"
<span class="brand-text-logo"><span class="brand-primary">GARDA</span><span class="brand-secondary">JABAR</span></span>
"@

$replaceCount = 0

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $pattern = '<img[^>]*src=["''][^"'']*' + [regex]::Escape($legacyLogoFile) + '[^"'']*["''][^>]*>'
        $newContent = [regex]::Replace($content, $pattern, $textBasedLogo, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated brand logo in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Brand logo replacement complete!"
Write-Host "Total files updated: $replaceCount"
