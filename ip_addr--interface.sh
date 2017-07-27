ifconfig $1 | grep -P -o '(?<=inet )[0-9.]+'
