read -p "Enter the domain to scan(eg: google.com): " domain

domain_ips=$(dig $domain +short) # Obtain ip address(es) from domain
# same domain can have multiple ip
# Of form 'dig <domain-url> +short'
# Domain is what's after "@" in an email address, or after "www." in a web address
# eg: google.com,gmail.com,students.iitmandi.ac.in,etc

echo -e "Enter the range of ports to scan(from 1 to 65535):"
read -p "Enter lower port limit: " lower_p
read -p "Enter upper port limit: " upper_p

date=$(date)
file_name="email_msg $date"

echo -e "\nGenerated from '$file_name.txt'\n" > "$file_name.txt" # intializing as blank file

IFS=$'\n'   # separator of ip(s)
# Looping in case there are multiple ip for same domain(eg:yahoo.in)
for ip in $domain_ips
do
    nmap_info=$(sudo nmap -p $lower_p-$upper_p $ip) # Scan for ALL the open ports on the ip address 
    #Scan a range of ports 	nmap -p 1-100 192.168.1.1
    # use just 'nmap_info=$(sudo nmap $ip)' to scan the most common 1,000 ports(Saves time)

    ip_info=$(curl https://ipinfo.io/$ip)

    whois_info=$(whois $ip | grep -vE "^#|^Comment:")
    # grep:
    # -v inverts the output for regex,printing what lines where RegEx is NOT present
    # -E is used to simulate OR(|) operator in the grep regex.
    # "^#|^Comment:" is a Regular Expression to select those statements
    # where line begins with '#' or 'Comments:' (removes irrelevant data in whois lookup)

    echo -e "Domain : $domain\nIP address=$ip\n\n$nmap_info\n$ip_info\n$whois_info\n\n" >> "$file_name.txt"
    
done

python mail.py "$file_name.txt"
# rm "$file_name.txt" # un-comment this line to delete the records once mailed to user

