●概要
  このツールは拡張子を偽装した画像、動画ファイルを検知します。
  検知対象は元の拡張子が
    JPG（JPEG）、PNG、GIF、BMP、MP4、AVI、MKV、MOV、WMV、HEIC、HEIF、HEVC 
  だったものです。
  ファイルのマジックナンバーと拡張子を比較し、マジックナンバーが上記画像、動画ファイルであるのに拡張子が異なる場合にコマンドラインにファイル名や元の拡張子等が出力されます。

●使い方
  １.「[動画、画像]拡張子偽装検知ツール.ps1」と「start.bat」を同じフォルダに置いてください。
  ２.「start.bat」を実行してください。
  ３.３種類のモードから選択を求められるので適宜選択してください。特段の理由が無ければ「1」を推奨します。
      ※１：対象拡張子同士での齟齬があった場合は除外するモード
      　２：JPEGとJPGの間のみ除外するモード（この２つはマジックナンバーが同じため）
        ３：全ての齟齬を検出するモード
  ４.次に対象とするフォルダの入力を求められるので入力して実行してください。
  ５.対象フォルダ以下の階層を全て調査し、選択したモードに応じて拡張子偽装を検知しコマンドライン上に出力します。

------------------------------------------

●Overview
    This tool detects image and video files with spoofed extensions.
  It detects image and video files whose original extensions are
    JPG (JPEG), PNG, GIF, BMP, MP4, AVI, MKV, MOV, WMV, HEIC, HEIF, HEVC, HEIC, HEIF, HEVC.
  If the magic number of the file and the file extension are compared, and the magic number is the above image or video file but the file extension is different, the file name, original file extension, etc. will be output to the command line.

●How to use
  1. Place “[Video, Image] File extension disguise detection tool.ps1” and “start.bat” in the same folder.
  Run “start.bat”.
  3. You will be asked to select one of three modes. If there is no particular reason, “1” is recommended.
      1: Exclude any discrepancies between the target extensions.
      　2: Mode to exclude only between JPEG and JPG (because these two have the same magic number).
        3: Mode to detect all discrepancies
  4. Next, you will be asked to enter the target folder.
  5. All hierarchies below the target folder will be examined, and depending on the mode selected, extension spoofing will be detected and output on the command line.
