##firewall
# Collect firewall log from c:\windows\system32\logfiles\firewall\

# Import log files

$firewall_raw = get-content D:\ELK-IR\aaron-box-pfirewall.log

$i = $firewall_raw.count
$fw = $firewall_raw[5..$i]

$fw_obj = @()
$nodns = "null"

foreach($f in $fw){

$l = $f.split(" ")

$properties = @{

    Computer_Name = $env:COMPUTERNAME
    Domain_Name = $env:USERDOMAIN
    #can split these later but elastic search seamed to pull this type okay.
    date_time = [string]$l[0,1]
    action = $l[2]
    protocol = $l[3]
    srcip = $l[4]
    #srcdns = try{[string](resolve-dnsName $l[4] -ErrorAction SilentlyContinue).NameHost}catch{$nodns}finally{}
    dstip = $l[5]
    #dstdns = try{[string](resolve-dnsName $l[5] -ErrorAction SilentlyContinue).NameHost}catch{$nodns}finally{}
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

}

$date = get-date -Format MM-dd-yy

$fw_obj | export-csv -NoTypeInformation -Encoding UTF8 -Delimiter "," d:/ELK-IR/veronica-pfirewall-$date.csv


#resolve dns in logstash
#overlay sites in geo tiles


##httperr

##smb client/server

##remote connections security

##rdp sessions

##terminal sessions


