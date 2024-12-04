# 拡張子ごとのマジックナンバーを定義
$magicNumbers = @{
    "JPG" = @()
    "JPEG" = @("FFD8FF", "FFD8FFE0", "FFD8FFE1", "FFD8FFE8")
    "PNG"  = @("89504E47")
    "GIF"  = @("47494638")
    "BMP"  = @("424D")
    "MP4"  = @("00000018667479706D703432", "000000186674797069736F6D", "00000020667479706D703432", "000000206674797069736F6D")
    "AVI"  = @("52494646", "41564920")
    "MKV"  = @("1A45DFA3")
    "MOV"  = @("000000146674797071742020", "000000206674797071742020")
    "WMV"  = @("3026B2758E66CF11A6D900AA0062CE6C")
    "HEIC" = @("000000186674797068656963")
    "HEIF" = @("000000186674797068656966")
    "HEVC" = @("000000186674797068657663")
}

#モード選択
Write-Output "拡張子偽装検知ツールを起動します。`n"
Write-Output "対象拡張子：JPEG,PNG,GIF,BMP,MP4,AVI,MKV,MOV,WMV,HEIC,HEIF,HEVC`n`n"
Write-Output "１：対象拡張子内での齟齬を除外モード`n"
Write-Output "２：JPEGとJPGの間のみ除外モード`n"
Write-Output "３：全検出モード`n"
$input = Read-Host "検索モードを選択してください`n"
if ($input -ge 1 -and $input -le 3) {
    $searchMode = $input
    } else { do {
    $searchMode = Read-Host "`n入力した文字をモードとして認識できませんでした`n上記モードに該当する数字を入力してください`n"
    } until ($searchMode -ge 1 -and $searchMode -le 3 )
}

# 調査したいパスを指定
$input = Read-Host "調査するフォルダを入力してください`n"
if (Test-Path $input) {
    $searchPath = $input
    } else { do {
    $searchPath = Read-Host "`n入力した文字列はパスとして認識できませんでした`n正確なパスを入力してください`n"
    } until (Test-Path $searchPath )
}

# 視覚的フィードバック用の変数
$processedFiles = 0
$mismatchCount = 0
$startTime = Get-Date
Write-Output "Scanning for mismatched files..."

# 読み込み用のバッファサイズを32バイトで設定
$buffer = New-Object byte[] 32

# 全ファイルを再帰的にスキャン (隠しファイル/フォルダを含む)
Get-ChildItem -Path $searchPath -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $file = $_
    $extension = $file.Extension -replace '^\.', '' # 拡張子から「.」を除去
    $extensionUpper = $extension.ToUpper()

    try {
        # ファイルの先頭バイトを読み込んでマジックナンバーを取得
        $fileStream = [System.IO.File]::OpenRead($file.FullName)
        $fileStream.Read($buffer, 0, $buffer.Length) | Out-Null
        $fileStream.Dispose()
        $fileMagic = ($buffer | ForEach-Object { $_.ToString("X2") }) -join ""

        # 各ファイルタイプのマジックナンバーと一致するか確認
        foreach ($format in $magicNumbers.Keys) {
            $matchFound = $magicNumbers[$format] | ForEach-Object { $fileMagic.StartsWith($_) }
            if ($matchFound -contains $true) {

                #入力したモードに応じて処理分岐
                switch($searchMode){
                    #１を選択：リスト除外モード       
                    1 {
                        #拡張子がリスト内と同一か判定
                        $isExtensionmatch = $magicNumbers.Keys -contains $extensionUpper

                        # 拡張子とマジックナンバーが一致しない場合に表示  
                        if (-not $isExtensionmatch -and $extensionUpper -ne $format) {
                                    Write-Output "`n検知: Path: $($file.FullName)`n ファイル名: $($file.Name)`n 元の拡張子: $format "
                                    $mismatchCount++
                                }
                                break
                    }
                
                    #２を選択：JPEGとJPGのみ除外
                    2 {
                        $isJpegJpgMismatch = $false

                        # JPEGとJPGの判定
                        if (($extensionUpper -eq "JPEG" -and $magicNumbers["JPEG"] -contains $fileMagic.Substring(0, 6)) -or
                            ($extensionUpper -eq "JPG" -and $magicNumbers["JPEG"] -contains $fileMagic.Substring(0, 6))) {
                            # 偽装を無視する場合、フラグを立てる
                            $isJpegJpgMismatch = $true
                        }
                        # 拡張子とマジックナンバーが一致しない場合に表示
                        if (-not $isJpegJpgMismatch -and $extensionUpper -ne $format) {
                            #Write-Output "`n検知: Path: $($file.FullName)`n ファイル名: $($file.Name)`n 元の拡張子: $format `n マジックナンバー: $fileMagic`n"
                            Write-Output "`n検知: Path: $($file.FullName)`n ファイル名: $($file.Name)`n 元の拡張子: $format "
                            $mismatchCount++
                        }
                        break
                    }

                    #３を選択：全検出モード
                    3 {
                        # 拡張子とマジックナンバーが一致しない場合に表示  
                        if ($extensionUpper -ne $format) {
                                    Write-Output "`n検知: Path: $($file.FullName)`n ファイル名: $($file.Name)`n 元の拡張子: $format "
                                    $mismatchCount++
                                }
                                break
                    }
                }
            }
        }

        $isExtensionMismatch = $magicNumbers.Keys | Foreach-Object { $_ -eq $extensionUpper} | Where-Object {$_ -eq $true} | Select-Object -First 1

    } catch {
        # 読み取りエラーが発生したファイルはスキップ
        Write-Verbose "Skipping file due to read error: $($file.FullName)"
    }

    # 処理済みファイルカウントと進行状況の視覚的フィードバック
    $processedFiles++
    if ($processedFiles % 1000 -eq 0) { Write-Host "." -NoNewline } # 1000ファイルごとに進行表示
}

# 処理時間と結果の表示
$endTime = Get-Date
$totalTime = $endTime - $startTime
Write-Output "対象フォルダ : $searchPath"
Write-Output "--- Scan Complete ---"
Write-Output "調査ファイル数: $processedFiles"
Write-Output "検知数: $mismatchCount"
Write-Output "所要時間: $($totalTime.Hours)h $($totalTime.Minutes)m $($totalTime.Seconds)s`n"
Write-Output "処理が完了しました。何かキーを入力すると画面が閉じます。"
