Add-Type -AssemblyName System.Web

$wc = New-Object system.Net.WebClient;
$wc.Encoding = [System.Text.Encoding]::UTF8;

$keyfrom = 'atupal-site';
$key = '401682907';

#[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
$OutputEncoding = [System.Text.Encoding]::UTF8;

function c {
    for($i=1; $i -le 150; $i++){echo ""}
}

function Get-Clipboard([switch] $Lines) {
    if($Lines) {
        $cmd = {
            Add-Type -Assembly PresentationCore
            [Windows.Clipboard]::GetText() -replace "`r", '' -split "`n"
        }
    } else {
        $cmd = {
            Add-Type -Assembly PresentationCore
            [Windows.Clipboard]::GetText()
        }
    }
    if([threading.thread]::CurrentThread.GetApartmentState() -eq 'MTA') {
        & powershell -Sta -Command $cmd
    } else {
        & $cmd
    }
}

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
    #param([Switch] $debug);
    Param(
        [Switch] $debug,
        [Switch] $copyMode,
        [Switch] $selectMode,
        [Switch] $balloon
    );
    
    function Show-BalloonTip  
    {
        [CmdletBinding(SupportsShouldProcess = $true)]
        param
        (
            [Parameter(Mandatory=$true)]
            $Text,
   
            [Parameter(Mandatory=$true)]
            $Title,
   
            [ValidateSet('None', 'Info', 'Warning', 'Error')]
            $Icon = 'Info',
            $Timeout = 10000
        )
 
        Add-Type -AssemblyName System.Windows.Forms

        if ($script:balloon -eq $null)
        {
            $script:balloon = New-Object System.Windows.Forms.NotifyIcon
        }
        $path                    = Get-Process -id $pid | Select-Object -ExpandProperty Path
        $script:balloon.Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
        $script:balloon.BalloonTipIcon  = $Icon
        $script:balloon.BalloonTipText  = $Text
        $script:balloon.BalloonTipTitle = $Title
        $script:balloon.Visible         = $true

        $script:balloon.ShowBalloonTip($Timeout)
    }

    #Show-BalloonTip -Text "sefd" -Title "nima" -Icon None -Timeout 5000;

    if ($copyMode -ne $false -or $selectMode -ne $false)
    {

        Add-Type -AssemblyName System.Windows.Forms;
        try
        {
            while ($true)
            {
                if ($selectMode -ne $false)
                {
                    #[System.Windows.Forms.SendKeys]::SendWait("^c");
                    # use "<ctrl-ins> but not "<ctrl-c>" to prevent terminal some programs(e.g. script)!
                    [System.Windows.Forms.SendKeys]::SendWait("^{INS}");
                    Start-Sleep -Milliseconds 200;
                }
                $currentText = Get-Clipboard;
                if (($currentText -ne $preText) -and ($currentText -match "^[a-zA-Z ,-.]+$"))
                {
                    $result_object = ydcv $currentText.trim() -balloon;

                    $title = "title";
                    $text = "text";
                    if ($result_object.query -ne $null)
                    {
                        $title = $result_object.query+' [{0} - {1}] ' -f $result_object.basic."uk-phonetic",$result_object.basic."us-phonetic" + $result_object.translation;
                    }
                    if ($result_object.basic.explains -ne $null)
                    {
                        $text = $result_object.basic.explains;
                    }
                    elseif ($result_object.translation -ne $null)
                    {
                        $text = $result_object.translation
                    }
                    Show-BalloonTip -Text $text -Title $title -Icon None -Timeout 5000;

                    $preText = $currentText;
                }
                if ($selectMode -eq $false) 
                {
                    Start-Sleep -Milliseconds 100;
                }
            }
        }
        catch
        {
            throw $_;
        }
        finally
        {
            $script:balloon.Dispose();
            Remove-Variable -Scope script -Name balloon;
            Write-Host "Bye!"
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

        if ($balloon -ne $false)
        {
            return $result_object;
        }
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
