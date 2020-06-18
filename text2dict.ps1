$threats = get-content D:\ELK-IR\intel\alltornodes.txt


$c = $threats.count
$i = 0
foreach($l in $threats){
$ip = $threats[$i]
$threats[$i].Replace($ip,"`"$ip`" : `"true`"") | out-file -Encoding utf8 D:\ELK-IR\intel\alltornodes-dict.txt -append
$i++
}
