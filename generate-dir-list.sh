#!/bin/sh

# Script to generate html files displaying folder structure.
# Originally copied the source from https://github.com/algesten/algesten.github.com


if [ "$1" = "" ]; then
    echo "Usage: $0 <dir>" >&1
    exit 1
fi

if [ ! -d "$1" ]; then
    echo \'$1\' is not a directory. >&1
    exit 1
fi

function escape {
    echo $1 | sed -e "s/</&lt;/g" | sed -e "s/&/&amp;/g"
}

function space {
    echo $1 | awk '{for (i = 0; i < $1; i++) printf " "}'
}

function generate {

    list=""

    if [ "`pwd`" != "$startdir" ]; then
        list="$list<a href=\"..\">../</a>"
    fi

    for a in *; do
        if [ $a == "index.html" ]; then continue; fi;

        info=`ls -lTd "$a"`

        size=`echo $info | awk '{print $5}'`
        date=`echo $info | awk '{printf ("%s-%s-%s %s",$6,$7,$9,$8)}'`

        if [ -d "$a" ]; then 
            a="${a}/"
            size="-"
        fi
        
        name=`escape "$a"`
        namelen=`echo $name | wc -m`
        let nameoff="60 - $namelen"

        sizelen=`echo $size | wc -m`
        let sizeoff="20 - $sizelen"
        
        line=`printf "<a href=\"%s\">%s</a>" "$name" "$name"``space $nameoff`${date}`space $sizeoff`${size}

        list="${list}
${line}"

    done

    bah="Index of /${base}`pwd | sed -e "s#$startdir##1"`"
    bah=`escape "$bah"`

    cat <<EOF >index.html
<html>
  <head>
    <title>${bah}</title>
  </head>
  <body>
    <h1>${bah}</h1>
    <hr>
    <pre>${list}</pre>
    <hr>
  </body>
</html>
EOF
}

function traverse {

    curdir=`pwd`

    for f in `find "$startdir" -type d`; do

        cd "$f"

        echo "Generating ${f}..."

        generate

        cd "$curdir"

    done
    
}

curdir=`pwd`
cd "$1"
startdir=`pwd`
base=`basename "$startdir"`
cd "$curdir"

traverse "$1"
