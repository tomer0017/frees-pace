
# freespace [-r] [-t ###] file [file...]
# If file is not compressed - will zip it under name “fc-<origname>”
# If file is compressed - will move it to name “fc-<origname>” and 'touch' it
# If file is called “fc-*” AND is older than 48 hours - will rm it
# If file is a folder - will go over all non-folder files in it
# If in recursive mode - will also follow folders recursively


zip_time=48
r_flag=0

check_file(){
  
      fileType=$(file -b --mime-type "$1")
      # echo "${fileType}"
      #check if zip
      if [ "${fileType}" = "application/zip" ] || [ "${fileType}" = "application/gzip" ] || [ "${fileType}" = "application/x-compress" ] || [ "${fileType}" = "application/x-bzip2" ] ; then
          # echo "$1 this is a zip file"

          #check if fc
          filename=$(basename -- "$1")
          extension="${filename##*.}"
          filename="${filename%.*}"
          if [[ $filename == "fc-"* ]]; then
              # echo "its a fc file"
              check_time $1
               
          else
            change_name $1
         
            
          fi  

      else 
          # echo "$1 unzip file" 
          zip_file $1
      fi
}







zip_file(){
    # echo "zip it"
    # echo "the file is $1"
    local fname=$(basename $1)
    # echo "${fname%%.*}"
    local fileType=$(file $fname | cut -d : -f 2)
    local newPath=$(echo $1 | sed -E "s/(.*)$fname/\1fc-${fname%%.*}/")
    zip -rm $newPath.zip $1 
    # echo "${newPath}"
 
}


change_name(){
local fname=$(basename $1)
local fileType=$(file $fname | cut -d : -f 2)
local newPath=$(echo $1 | sed -E "s/(.*)$fname/\1fc-$fname/")
mv $1 $newPath && touch $newPath
# echo "change name"
}



check_time(){

filemtime=`stat -c %Y $1`
currtime=`date +%s`
diff=$(( (currtime - filemtime) / 60 ))
# echo $diff

timeready=$((zip_time*60))
# echo $timeready
if [ $diff -ge $timeready ]; then
    rm $1
    # echo "$1 delet"
fi    
}



while getopts ":rt:" opt; do
  case ${opt} in
    r ) r_flag=1
        
      ;;
    t ) t=${OPTARG}
        # t_flag=0
        # (( t >= 0 &&  t != -r )) ||  echo "Usage: freespace [-r] [-t ###] file [file...]"
        # exit 1
        ;;
    \?) echo "Usage: freespace [-r] [-t ###] file [file...]"
      ;;
  esac
done
shift $((OPTIND -1))

if [ ! $# -gt 1 ] ; then
    # if [ "${t_flag}" = 0 ] ; then 
     echo "Usage: freespace [-r] [-t ###] file [file...]"
     exit 1
    # fi
fi
# echo "r=${r_flag}"
if [ ${t} ] ; then 
zip_time=${t}

fi
# echo "zip_time ${zip_time}"






for var in "$@"
do
    if [[ -d "$var" ]]; then  
        if [[ "${r_flag}" = 0 ]] ; then 
        for file in "$var"/* ; do 
           if [[ -f "$file" ]]; then  
           check_file $file
           fi
        done
        fi

        if [[ "${r_flag}" = 1 ]] ; then 
        find . -path '*/'$var'/*' -print0 | while IFS= read -r -d '' file
        do 
          if [[ -f "$file" ]]; then  
           check_file $file
          fi
        done
        fi
    fi
    #check if file
    if [[ -f "$var" ]]; then  
     
      check_file $var
    
   fi
done   

















# for var in "$@"
# do
#     if [[ -f "$var" ]]; then
#     zip_file $var
#     fileType=$(file -b --mime-type "$var")
#     if [ "${fileType}" = "application/zip" || "application/gzip" || "application/x-compress" ||  "application/x-bzip2" ] ; then
#     echo "this is a zip file"
#     echo "$var"
#     check_zip "$var"
#     else echo $var

#     fi
    
#    fi

    
#    for file in "$var"/*; do

#     fileType=$(file -b --mime-type "$file")
#     if [ "${fileType}" = "application/zip" ] ; then
#     echo "this is a zip file"
#     check_zip "$file"

#     elif [[ -f "$file" ]]; then
#     zip_file $file
#     echo $file

#     fi
#     done
# done





