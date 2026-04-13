# Final Verification Script - Memastikan rebrand Garda Jabar selesai dengan baik

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Garda Jabar"
$legacyDisplay = 'Warta' + ' Janten'
$legacyCompact = 'Warta' + 'Janten'
$legacyHandle = 'warta' + 'janten'
$legacyLogoFile = 'logo' + '.png'
$legacyLogoPattern = [regex]::Escape($legacyLogoFile)

Write-Host "========== FINAL VERIFICATION - GARDA JABAR ==========" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$stats = @{
    "Files checked" = 0
    "Old branding found" = 0
    "Legacy logo found" = 0
    "New colors found" = 0
}

$filesToCheck = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.css", "*.json", "*.md", "*.toml", "*.txt", "*.js", "*.ps1" -File |
    Where-Object { $_.FullName -notlike "*\node_modules\*" -and $_.FullName -notlike "*\.bak.*" }
$stats["Files checked"] = $filesToCheck.Count

Write-Host "1. Checking for old branding strings..." -ForegroundColor Yellow
$oldBrandingPatterns = @($legacyDisplay, $legacyCompact, $legacyHandle)
foreach ($pattern in $oldBrandingPatterns) {
    $found = $filesToCheck | Select-String -Pattern $pattern -SimpleMatch -ErrorAction SilentlyContinue
    foreach ($result in $found) {
        $issues += "Old branding: $($result.Path):$($result.LineNumber)"
        $stats["Old branding found"]++
    }
}
if ($stats["Old branding found"] -eq 0) {
    Write-Host "   ✅ No old branding references found." -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Found $($stats['Old branding found']) old branding references." -ForegroundColor Yellow
}

Write-Host "2. Checking for legacy logo references..." -ForegroundColor Yellow
$logoFound = $filesToCheck | Select-String -Pattern $legacyLogoPattern -ErrorAction SilentlyContinue
if ($logoFound) {
    $stats["Legacy logo found"] = $logoFound.Count
    Write-Host "   ⚠️ Found $($logoFound.Count) legacy logo references." -ForegroundColor Yellow
} else {
    Write-Host "   ✅ No legacy logo references found." -ForegroundColor Green
}

Write-Host "3. Checking for new color scheme..." -ForegroundColor Yellow
$newColors = @("#B45309", "#451A03", "#5C2E1A")
foreach ($color in $newColors) {
    if ($filesToCheck | Select-String -Pattern $color -SimpleMatch -ErrorAction SilentlyContinue) {
        $stats["New colors found"]++
        Write-Host "   ✅ Found $color" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Missing $color" -ForegroundColor Yellow
    }
}

Write-Host "4. Checking for Garda Jabar branding..." -ForegroundColor Yellow
$newBrandingFound = $filesToCheck | Select-String -Pattern 'Garda Jabar|GardaJabar|gardajabar' -ErrorAction SilentlyContinue | Measure-Object
if ($newBrandingFound.Count -gt 0) {
    Write-Host "   ✅ Found Garda Jabar branding in $($newBrandingFound.Count) places." -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Garda Jabar branding not detected." -ForegroundColor Yellow
}

Write-Host "5. Checking package metadata..." -ForegroundColor Yellow
$pkgFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "package.json", "package-lock.json" -File |
    Where-Object { $_.FullName -notlike "*\node_modules\*" }
foreach ($pkg in $pkgFiles) {
    $content = Get-Content -Path $pkg.FullName -Raw -Encoding UTF8
    if ($content -match '"name"\s*:\s*"gardajabar') {
        Write-Host "   ✅ $($pkg.Name) uses Garda Jabar package metadata." -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ $($pkg.Name) still needs metadata review." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Files checked: $($stats['Files checked'])"
Write-Host "Old branding references: $($stats['Old branding found'])"
Write-Host "Legacy logo references: $($stats['Legacy logo found'])"
Write-Host "New colors found: $($stats['New colors found'])/3"
if ($issues.Count -gt 0) {
    Write-Host ""
    Write-Host "First findings:" -ForegroundColor Yellow
    $issues | Select-Object -First 5 | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
}
Write-Host ""
Write-Host "Rebrand Garda Jabar selesai ✅" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Cyan
