##firewall
# Collect firewall log from c:\windows\system32\logfiles\firewall\
#setup path to project
#$project_root_path = Read-host "Input the path to the ELK-IR folder(ex. C:\ELK-IR):"
# Import log files
$firewall_raw = get-content D:\ELK-IR\data\Firewalllogs\home-june-2020\pfirewall-veronica-june-20-2.log
#removing the top preample that does not contain usable data.
$i = $firewall_raw.count
$fw = $firewall_raw[5..$i]

#initializing hashtable and required variables
$fw_obj = @()
$nodns = "null"
#add option to hard set if this does not validate!
$external_ip_perm = (Invoke-WebRequest -UseBasicParsing -uri "http://ifconfig.me/ip").Content
#run through each line entriching data accordingly.
$c = $fw.count
$i = 1
foreach($f in $fw){
write-progress -Activity "Parsing and enriching windows host fw data from firwall.log" -Status "$i Complete out of $c" -percentcomplete ($i/$c*100)
$f = $f.replace("-","0")
$l = $f.split(" ")
$l[0]=$l[0][0,1,2,3]+"-"+$l[0][5,6]+"-"+$l[0][8,9]
$l[0]=$l[0].replace(" ","")
#
$externalsrc_ip = if($l[4] -eq "127.0.0.1" -or $l[4] -like "192.168.*" -or $l[4] -like "10.*" -or $l[4] -like "172.16.*" -or $l[4] -like "172.17.*" -or $l[4] -like "172.18.*" -or $l[4] -like "172.19.*" -or $l[4] -like "172.20.*" -or $l[4] -like "172.21.*" -or $l[4] -like "172.22.*" -or $l[4] -like "172.23.*" -or $l[4] -like "172.24.*" -or $l[4] -like "172.25.*" -or $l[4] -like "172.26.*" -or $l[4] -like "172.27.*" -or $l[4] -like "172.28.*" -or $l[4] -like "172.29.*" -or $l[4] -like "172.30.*" -or $l[4] -like "172.31.*"){$external_ip_perm}else{$l[4]}
$externaldst_ip = if($l[5] -eq "127.0.0.1" -or $l[5] -like "192.168.*" -or $l[5] -like "10.*" -or $l[5] -like "172.16.*" -or $l[5] -like "172.17.*" -or $l[5] -like "172.18.*" -or $l[5] -like "172.19.*" -or $l[5] -like "172.20.*" -or $l[5] -like "172.21.*" -or $l[5] -like "172.22.*" -or $l[5] -like "172.23.*" -or $l[5] -like "172.24.*" -or $l[5] -like "172.25.*" -or $l[5] -like "172.26.*" -or $l[5] -like "172.27.*" -or $l[5] -like "172.28.*" -or $l[5] -like "172.29.*" -or $l[5] -like "172.30.*" -or $l[5] -like "172.31.*"){$external_ip_perm}else{$l[5]}
#too slow maybe need async option or one lookup that feeds a table that it matches. Then can remove nulls & add [system.net.dns]::GetHostByAddress($l[5]).hostname} with feed into lookup function that stores known addresses temporarily in hash table.  Maybe even just prints them for reference.
$internalsrc_dns = if($l[4] -eq "127.0.0.1" -or $l[4] -like "192.168.*" -or $l[4] -like "10.*" -or $l[4] -like "172.16.*" -or $l[4] -like "172.17.*" -or $l[4] -like "172.18.*" -or $l[4] -like "172.19.*" -or $l[4] -like "172.20.*" -or $l[4] -like "172.21.*" -or $l[4] -like "172.22.*" -or $l[4] -like "172.23.*" -or $l[4] -like "172.24.*" -or $l[5] -like "172.25.*" -or $l[4] -like "172.26.*" -or $l[4] -like "172.27.*" -or $l[4] -like "172.28.*" -or $l[4] -like "172.29.*" -or $l[4] -like "172.30.*" -or $l[4] -like "172.31.*"){$null}else{$null}
$internaldst_dns = if($l[5] -eq "127.0.0.1" -or $l[5] -like "192.168.*" -or $l[5] -like "10.*" -or $l[5] -like "172.16.*" -or $l[5] -like "172.17.*" -or $l[5] -like "172.18.*" -or $l[5] -like "172.19.*" -or $l[5] -like "172.20.*" -or $l[5] -like "172.21.*" -or $l[5] -like "172.22.*" -or $l[5] -like "172.23.*" -or $l[5] -like "172.24.*" -or $l[5] -like "172.25.*" -or $l[5] -like "172.26.*" -or $l[5] -like "172.27.*" -or $l[5] -like "172.28.*" -or $l[5] -like "172.29.*" -or $l[5] -like "172.30.*" -or $l[5] -like "172.31.*"){$null}else{$null}

$properties = [ordered]@{

    Computer_Name = $env:COMPUTERNAME
    Domain_Name = $env:USERDOMAIN
    #can split these later but elastic search seamed to pull this type okay.
    date_time = [string]$l[0,1]
    action = $l[2]
    protocol = $l[3]
    srcip = $l[4]
    srcdns = $internalsrc_dns
    extsrcip = $externalsrc_ip
    extsrcdns = $externalsrc_ip
    dstip = $l[5]
    dstdns = $internaldst_dns
    extdstip = $externaldst_ip
    extdstdns = $externaldst_ip
    srcport = $l[6]
    dstport = $l[7]
    size = $l[8]
    tcpflags = $l[9]
    tcpsyn = $l[10]
    tcpack = $l[11]
    tcpwin = $l[12]
    icmptype = $l[13]
    icmpcode = $l[14]
    info = $l[15]
    path = $l[16]                               
}

$obj = New-Object -TypeName psobject -Property $properties

$fw_obj += $obj
$i = $i +1

}

$date = get-date -Format MM-dd-yy-HH-mm-ss

$fw_obj | export-csv -NoTypeInformation -Encoding UTF8 -Delimiter "," d:\ELK-IR\data\logstash-datadump\homeset-$date.csv

<##################################################################httperr log########################################################



##httperr
$httperr = get-content C:\windows\System32\logfiles\HTTPERR\httperr1.log





##################################################################smb client/server connections#######################################

### dump smb pipes
$smb_connections_live = get-smbconnection 
$smb_cnnection_live | Export-Csv -LiteralPath $env:COMPUTERNAME+"smb_connections_live-$date.csv"

#code for later cobalt strike beacons can be found here
#[system.io.directory]::getfiles("\\.\\pipe\\")


##SMBClient Connectivity
$smbclient = Get-winevent microsoft-windows-smbclient/connectivity

##SMBServer Connectivity
$smbclient = Get-winevent microsoft-windows-smbserver/connectivity

## RDP

##rdp sessions
### Terminal Sessions Events#>



