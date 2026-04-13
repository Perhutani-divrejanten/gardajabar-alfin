# Rebrand portal berita statis ke Garda Jabar
# Menjaga encoding UTF-8, membuat backup articles.json.bak, dan memperbarui branding + warna.

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$WorkspaceRoot = $PSScriptRoot
$legacyDisplay = 'Warta' + ' Janten'
$legacyCompact = 'Warta' + 'Janten'
$legacyHandle = 'warta' + 'janten'
$legacyLogoFile = 'logo' + '.png'
$legacyLogoPath = 'img/' + $legacyLogoFile
$brandLogo = '<span class="brand-text-logo"><span class="brand-primary">GARDA</span><span class="brand-secondary">JABAR</span></span>'
$stats = [ordered]@{
    main_pages   = 0
    article_pages = 0
    css          = 0
    package      = 0
    docs         = 0
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Normalize-Content {
    param([string]$Content)

    $normalized = $Content
    $normalized = $normalized.Replace([char]0x201C, '"')
    $normalized = $normalized.Replace([char]0x201D, '"')
    $normalized = $normalized.Replace([char]0x2018, "'")
    $normalized = $normalized.Replace([char]0x2019, "'")
    $normalized = $normalized.Replace([char]0x2013, '-')
    $normalized = $normalized.Replace([char]0x2014, '-')
    $normalized = $normalized.Replace([char]0x00A0, ' ')
    $normalized = $normalized.Replace([char]0xFFFD, ' ')

    return $normalized
}

function Apply-Replacements {
    param(
        [string]$Content,
        [System.Collections.Specialized.OrderedDictionary]$Map
    )

    foreach ($key in $Map.Keys) {
        $Content = $Content -replace [regex]::Escape([string]$key), [string]$Map[$key]
    }

    return $Content
}

$sharedReplacements = New-Object System.Collections.Specialized.OrderedDictionary
$sharedReplacements.Add('Indonesia Daily', 'Garda Jabar')
$sharedReplacements.Add('IndonesiaDaily', 'GardaJabar')
$sharedReplacements.Add('indonesiadaily', 'gardajabar')
$sharedReplacements.Add($legacyDisplay, 'Garda Jabar')
$sharedReplacements.Add($legacyCompact + '33@gmail.com', 'gardajabar@gmail.com')
$sharedReplacements.Add($legacyHandle + '33@gmail.com', 'gardajabar@gmail.com')
$sharedReplacements.Add($legacyCompact, 'GardaJabar')
$sharedReplacements.Add($legacyHandle, 'gardajabar')
$sharedReplacements.Add('https://twitter.com/GardaJabar', 'https://twitter.com/gardajabar')
$sharedReplacements.Add('https://facebook.com/GardaJabar', 'https://facebook.com/gardajabar')
$sharedReplacements.Add('https://instagram.com/GardaJabar', 'https://instagram.com/gardajabar')
$sharedReplacements.Add('https://youtube.com/@GardaJabar', 'https://youtube.com/@gardajabar')
$sharedReplacements.Add('https://linkedin.com/company/GardaJabar', 'https://linkedin.com/company/gardajabar')
$sharedReplacements.Add('#065F46', '#B45309')
$sharedReplacements.Add('#1E3A5F', '#5C2E1A')
$sharedReplacements.Add('#022C22', '#451A03')
$sharedReplacements.Add('#FFCC00', '#B45309')
$sharedReplacements.Add('#ffcc00', '#B45309')
$sharedReplacements.Add('#1E2024', '#451A03')
$sharedReplacements.Add('#1e2024', '#451A03')
$sharedReplacements.Add('#31404B', '#5C2E1A')
$sharedReplacements.Add('#b38f00', '#92400E')
$sharedReplacements.Add('--primary: #fc0;', '--primary: #B45309;')
$sharedReplacements.Add('--secondary: #1E3A5F;', '--secondary: #5C2E1A;')
$sharedReplacements.Add('--dark: #022C22;', '--dark: #451A03;')

$docsReplacements = New-Object System.Collections.Specialized.OrderedDictionary
foreach ($key in $sharedReplacements.Keys) {
    $docsReplacements.Add($key, $sharedReplacements[$key])
}
$docsReplacements.Add($legacyLogoPath, 'text-based brand logo')
$docsReplacements.Add($legacyLogoFile, 'legacy brand image')
$legacyLogoRegex = [regex]::Escape($legacyLogoFile)

$cssBrandBlock = @"
/* Garda Jabar text logo */
.brand-text-logo {
  display: inline-flex;
  align-items: baseline;
  gap: 2px;
  line-height: 1;
}

.brand-text-logo .brand-primary {
  font-weight: 700;
  color: var(--primary);
  font-size: 24px;
  letter-spacing: -0.5px;
}

.brand-text-logo .brand-secondary {
  font-weight: 500;
  color: var(--secondary);
  font-size: 18px;
}
"@

if (Test-Path (Join-Path $WorkspaceRoot 'articles.json')) {
    Copy-Item -Path (Join-Path $WorkspaceRoot 'articles.json') -Destination (Join-Path $WorkspaceRoot 'articles.json.bak') -Force
}

Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.html | ForEach-Object {
    if ($_.FullName -like '*\.bak*' -or $_.FullName -like '*\node_modules\*') {
        return
    }

    $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    $updated = Normalize-Content $content
    $updated = Apply-Replacements -Content $updated -Map $sharedReplacements
    $updated = $updated -replace ' - GardaJabar', ' - Garda Jabar'
    $updated = $updated -replace '>GardaJabar<', '>Garda Jabar<'
    $updated = $updated -replace 'GardaJabar adalah portal berita', 'Garda Jabar adalah portal berita'
    $updated = $updated -replace 'Tentang GardaJabar', 'Tentang Garda Jabar'
    $updated = $updated -replace 'newsletter GardaJabar', 'newsletter Garda Jabar'

    $updated = [regex]::Replace(
        $updated,
        '(<a\b[^>]*class="[^"]*navbar-brand[^"]*"[^>]*>)([\s\S]*?)(</a>)',
        { param($m) "$($m.Groups[1].Value)$brandLogo$($m.Groups[3].Value)" },
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    $logoPattern = '<img[^>]*src=["''][^"'']*' + [regex]::Escape($legacyLogoFile) + '[^"'']*["''][^>]*>'
    $updated = [regex]::Replace($updated, $logoPattern, $brandLogo, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($updated -ne $content) {
        Write-Utf8File -Path $_.FullName -Content $updated
        if ($_.FullName -like '*\article\*') {
            $stats.article_pages++
        } else {
            $stats.main_pages++
        }
    }
}

Get-ChildItem -Path (Join-Path $WorkspaceRoot 'css') -Recurse -Include *.css -File | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    $updated = Normalize-Content $content
    $updated = Apply-Replacements -Content $updated -Map $sharedReplacements
    $updated = $updated -replace 'a:hover\s*\{\s*color:\s*#92400E;', 'a:hover {`r`n  color: #92400E;'

    if ($_.Name -eq 'style.css' -and $updated -notmatch 'brand-text-logo') {
        $updated = $updated -replace '/\* Prevent horizontal page dragging/overflow on pages with wide elements \*/', "$cssBrandBlock`r`n/* Prevent horizontal page dragging/overflow on pages with wide elements */"
    }

    if ($_.Name -eq 'style.min.css' -and $updated -notmatch 'brand-text-logo') {
        $updated += '.brand-text-logo{display:inline-flex;align-items:baseline;gap:2px;line-height:1}.brand-text-logo .brand-primary{font-weight:700;color:var(--primary);font-size:24px;letter-spacing:-.5px}.brand-text-logo .brand-secondary{font-weight:500;color:var(--secondary);font-size:18px}'
    }

    if ($updated -ne $content) {
        Write-Utf8File -Path $_.FullName -Content $updated
        $stats.css++
    }
}

@(
    'package.json',
    'package-lock.json',
    'tools\package.json'
) | ForEach-Object {
    $filePath = Join-Path $WorkspaceRoot $_
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        $updated = Normalize-Content $content
        $updated = Apply-Replacements -Content $updated -Map $sharedReplacements
        $updated = $updated -replace '"name"\s*:\s*"GardaJabar"', '"name": "gardajabar"'
        $updated = $updated -replace '"name"\s*:\s*"gardajabar-article-generator"', '"name": "gardajabar-article-generator"'
        if ($updated -ne $content) {
            Write-Utf8File -Path $filePath -Content $updated
            $stats.package++
        }
    }
}

@(
    'AUTOMATION_README.md',
    'GOOGLE_DRIVE_GUIDE.md',
    'GOOGLE_DRIVE_IMAGES_GUIDE.md',
    'netlify.toml',
    'PERBAIKAN_STATUS.md',
    'SEARCH_SETUP.md',
    'TROUBLESHOOTING.md',
    'READ-ME.txt',
    'REBRAND_SUMMARY.txt',
    'replace-logo.ps1',
    'final-verification.ps1',
    'rebrand-to-warta-janten.ps1'
) | ForEach-Object {
    $filePath = Join-Path $WorkspaceRoot $_
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw -Encoding UTF8
        $updated = Normalize-Content $content
        $updated = Apply-Replacements -Content $updated -Map $docsReplacements
        if ($updated -ne $content) {
            Write-Utf8File -Path $filePath -Content $updated
            $stats.docs++
        }
    }
}

$generateJsPath = Join-Path $WorkspaceRoot 'tools\generate.js'
if (Test-Path $generateJsPath) {
    $content = Get-Content -Path $generateJsPath -Raw -Encoding UTF8
    $updated = Normalize-Content $content
    $updated = Apply-Replacements -Content $updated -Map $sharedReplacements
    $updated = $updated -replace ("\s*!src\.includes\('" + $legacyLogoRegex + "'\)\s*&&"), ''
    $updated = $updated -replace ("return 'img/" + $legacyLogoRegex + "';"), "return 'img/news-800x500-1.jpg';"
    if ($updated -ne $content) {
        Write-Utf8File -Path $generateJsPath -Content $updated
        $stats.docs++
    }
}

Write-Host ''
Write-Host '===== REBRAND GARDA JABAR =====' -ForegroundColor Cyan
Write-Host ("Main pages: {0}" -f $stats.main_pages)
Write-Host ("Article pages: {0}" -f $stats.article_pages)
Write-Host ("CSS: {0}" -f $stats.css)
Write-Host ("Package: {0}" -f $stats.package)
Write-Host ("Docs: {0}" -f $stats.docs)
Write-Host 'Rebrand Garda Jabar selesai ✅' -ForegroundColor Green
