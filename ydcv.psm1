Add-Type -AssemblyName System.Web

$wc = New-Object system.Net.WebClient;
$wc.Encoding = [System.Text.Encoding]::UTF8;

$keyfrom = 'atupal-site';
$key = '401682907';

#[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
$OutputEncoding = [System.Text.Encoding]::UTF8;

function print_explanation()
{
    #[CmdletBinding()];
    param([Switch] $debug);
    $obj = $args[0];
    if ($debug -ne $false)
    {
        write-host ($result | ConvertFrom-Json | ConvertTo-Json);
    }
        
    Write-Host $obj.query -NoNewline -ForegroundColor Red -BackgroundColor Yellow;
    Write-Host " " -NoNewline;
    if ($obj.basic -ne $null)
    {
        $b = $obj.basic;
        '[{0} - {1}] ' -f $b."uk-phonetic",$b."us-phonetic" | Write-Host -ForegroundColor Yellow -NoNewline;
        Write-Host $obj.translation -ForegroundColor Green;
        if ($b.explains -ne "null")
        {
            Write-Host "  Word Explanation:" -ForegroundColor Cyan;
            foreach ($e in $_b.explains)
            {
                "    * {0}" -f $e | write-host;
            }
        }
    }
    elseif ($obj.translation -ne $null)
    {
        foreach ($e in $obj.translation)
        {  
            "    * {0}" -f $e | Write-Host;
        }
    }
    if ($obj.web -ne $null)
    {
        $w = $obj.web;
        Write-Host;
        Write-Host "  Web Reference:" -ForegroundColor Cyan;
        foreach ($o in $w)
        {
            "    * {0}" -f $o.key | Write-Host -ForegroundColor Yellow;
            "      {0}" -f [string]::Join(" ", $o.value) | Write-Host -ForegroundColor Magenta;
        }

    }
}

function ydcv()
{
    param(
        [Switch] $debug,
        [Switch] $copyMode
    );

    if ($copyMode -ne $false)
    {
        while ($true)
        {
            $currentText = Get-Clipboard;
            if (($currentText -ne $preText) -and ($currentText -match "^[a-zA-Z ]+$"))
            {
                ydcv $currentText;
                $preText = $currentText;
            }
            Start-Sleep -Milliseconds 100;
        }

    }
    
    foreach ($arg in $args)
    {
    	$query = [System.Web.HttpUtility]::UrlEncode($arg);
    	$url = 'http://fanyi.youdao.com/openapi.do?keyfrom=' `
	    + $keyfrom + '&key=' `
	    + $key + '&type=data&doctype=json&version=1.1&q=' + $query;
	    $result = $wc.DownloadString($url);
	    $result_object = ($result | ConvertFrom-Json);
	    print_explanation $result_object -debug:$debug.ToBool();
	    #write-host ($result | ConvertFrom-Json | ConvertTo-Json);
    }
}

function speak($word)
{
    Add-Type -AssemblyName System.speech;
    $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer;
    $speak.Speak($word);
}

function sw()
{
    Invoke-Expression "ydcv $args";
    speak $args[0];
}
