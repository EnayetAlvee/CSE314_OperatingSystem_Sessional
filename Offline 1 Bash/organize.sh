#!/usr/bin/bash




target_dir="$2"
submission_dir="$1"
test_dir="$3"
ans_dir="$4"



rm -rf "$target_dir"




shift 4
verbose=false
no_execute=false
no_lc=false
no_cc=false
no_fc=false

#parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v)
            verbose=true
            ;;
        -noexecute)
            no_execute=true
            ;;
        -nolc)
            no_lc=true
            ;;
        -nocc)
            no_cc=true
            ;;
        -nofc)
            no_fc=true
            ;;
        *)
            echo "Unknown option: $1"
            # exit 1``
            ;;
    esac
    shift
done



mkdir -p "$target_dir"
mkdir -p "$target_dir/C"
mkdir -p "$target_dir/C++"
mkdir -p "$target_dir/Python"
mkdir -p "$target_dir/Java"

# echo "starting"
# submissions_folder="$1"
# rm -rf $target_dir
rm -rf unzipped

for file in ./submissions/*; do
# echo "Processing $file"
    unzip "$file" -d "unzipped" > /dev/null 2>&1
done



csv_file="$target_dir/result.csv"

# rm -rf "$csv_file"
# touch "$csv_file"


csv_header="student_id,student_name,language"

if [ "$no_execute" = false ]; then
    csv_header="$csv_header,matched,not_matched"
fi
if [ "$no_lc" = false ]; then
    csv_header="$csv_header,line_count"
fi
if [ "$no_cc" = false ]; then
    csv_header="$csv_header,comment_count"
fi
if [ "$no_fc" = false ]; then
    csv_header="$csv_header,function_count"
fi

# echo "$csv_header" > "$csv_file"
echo $csv_header



if [ ! -f "$csv_file" ]; then
    echo "$csv_header" > "$csv_file"
fi

# for file in ./unzipped/*; do
#     if [[ -d $file ]]; then
#         student_id=$(basename "$file")
#         student_name=$(echo "$student_id" | sed 's/_[0-9]*$//')
#         echo "Student ID: $student_id"
#         echo "Student Name: $student_name"
        
#         # Move files to respective folders based on their extensions
#         for code_file in "$file"/*; do
#             case "${code_file}" in
#                 *.c) mv "$code_file" "$target_dir/C/" ;;
#                 *.cpp) mv "$code_file" "$target_dir/C++/" ;;
#                 *.py) mv "$code_file" "$target_dir/Python/" ;;
#                 *.java) mv "$code_file" "$target_dir/Java/" ;;
#             esac
#         done
#     fi
# done
# var=1
# echo var

for file in ./unzipped/* ; do
    codefile=$(find "$file" -type f \( -iname "*.c" -o -iname "*.cpp" -o -iname "*.java" -o -iname "*.py" \))
    fullpath="$codefile"
    # echo $var
    # var=$((var+1))

    codefile=$(basename "$codefile")
    extention="${codefile##*.}"
    file=$(basename "$file")
    name="${file%%_*}"   #storing the name of the student
    serial_num="${file:$((${#name}+1)):7}" 
    student_id="${file: -7}"  #storing id


    # echo "--------------------------"
    # echo "processing $file"
    # echo "name:$name"
    # echo "serial_num:$serial_num"
    # echo "student_id:$student_id"
    # echo "codefile:$codefile"
    # echo "extention:$extention"

    line_count=$(wc -l < "$fullpath")
    # echo "line_count:$line_count"
    declare -i comment_count=0
    declare   lang
    declare -i function_count
    current_path=$(pwd)
    # echo "current_path:$current_path"
    if [ "$verbose" = true ]; then
        echo "organizing files of $student_id"
        if [ "$no_execute" = false ]; then
            echo "Executing files of $student_id"
        fi
    fi

    case "$extention" in
        c) mkdir "$target_dir/C/$student_id" 
            mv "$fullpath" "$target_dir/C/$student_id/main.c"

            comment_count=$(grep -c "//" "$target_dir/C/$student_id/main.c")
            function_count=$(grep -c -E "^\s*(static\s+|inline\s+)?\w+\s+\w+\s*\(.*\)\s*\{" "$target_dir/C/$student_id/main.c")
            lang="C"
            

            #calculate function count in main.c
        

            
            #test cases are  in $test_dir argument
            # temp_count=1

            #in no execute mode,
            

            if [ "$no_execute" = false ]; then
                cd "$target_dir/C/$student_id"
                gcc  "main.c" -o "main.out" #2> /dev/null
                cd "$current_path"
                for test_file in "$test_dir"/*; do
                    test_file_name=$(basename "$test_file")
                    # echo "test_file:$test_file_name"
                    
                    #copy test file to student folder
                    cp "$test_file" "$target_dir/C/$student_id/$test_file_name"
                    cd "$target_dir/C/$student_id"

                    temp_count=$(echo "$test_file_name" | grep -o '[0-9]\+')
                    
                    outputfilename="out$temp_count.txt"

                    rm -f "$outputfilename"
                    rm -f "out$temp_count"
                    rm -f "out0"

                    ./main.out < "$test_file_name" > "$outputfilename"
                    
                    #remove the test file
                    rm "$test_file_name"
                    # ls
                    # temp_count=$((temp_count + 1))
                    cd "$current_path"
                    # cd "$target_dir/C/$student_id"

                    #./main.out < "$test_file" > "$test_file_name.out"
                    #./main.out < "$test_file" > "$target_dir/C/$student_id/$test_file_name.out"
                done


                match_count=0
                no_match_count=0

                for ans_file in "$ans_dir"/*; do
                    ans_file_name=$(basename "$ans_file")
                    temp_count=$(echo "$ans_file_name" | grep -o '[0-9]\+')
                    # echo "Answer file: $ans_file_name"
                    if diff -q "$ans_file" "$target_dir/C/$student_id/out$temp_count.txt" > /dev/null; then
                        match_count=$((match_count + 1))
                    else
                        no_match_count=$((no_match_count + 1))
                    fi

                done
                
            fi
           
            

            # echo "Match count: $match_count"
            # echo "No match count: $no_match_count"
        ;;
        cpp) mkdir "$target_dir/C++/$student_id" 
            mv "$fullpath" "$target_dir/C++/$student_id/main.cpp"
            comment_count=$(grep -c "//" "$target_dir/C++/$student_id/main.cpp")
            function_count=$(grep -c -E "^\s*(static\s+|inline\s+|virtual\s+)?\w+\s+\w+\s*\(.*\)\s*\{" "$target_dir/C++/$student_id/main.cpp")

            lang="C++"
            


            if [ "$no_execute" = false ]; then
                cd "$target_dir/C++/$student_id"
                g++ "main.cpp" -o "main.out" #2> /dev/null
                cd "$current_path"

                for test_file in "$test_dir"/*; do
                    test_file_name=$(basename "$test_file")
                    # echo "test_file:$test_file_name"
                    
                    #copy test file to student folder
                    cp "$test_file" "$target_dir/C++/$student_id/$test_file_name"
                    cd "$target_dir/C++/$student_id"

                    temp_count=$(echo "$test_file_name" | grep -o '[0-9]\+')
                    
                    outputfilename="out$temp_count.txt"

                    rm -f "$outputfilename"
                    rm -f "out$temp_count"
                    rm -f "out0"

                    ./main.out < "$test_file_name" > "$outputfilename"
                    
                    #remove the test file
                    rm "$test_file_name"
                    # ls
                    # temp_count=$((temp_count + 1))
                    cd "$current_path"
                    # cd "$target_dir/C/$student_id"

                    #./main.out < "$test_file" > "$test_file_name.out"
                    #./main.out < "$test_file" > "$target_dir/C/$student_id/$test_file_name.out"
                done
                match_count=0
                no_match_count=0

                for ans_file in "$ans_dir"/*; do
                    ans_file_name=$(basename "$ans_file")
                    temp_count=$(echo "$ans_file_name" | grep -o '[0-9]\+')
                    # echo "Answer file: $ans_file_name"
                    if diff -q "$ans_file" "$target_dir/C++/$student_id/out$temp_count.txt" > /dev/null; then
                        match_count=$((match_count + 1))
                    else
                        no_match_count=$((no_match_count + 1))
                    fi

                done
            fi         
            #  echo "Match count: $match_count"
            # echo "No match count: $no_match_count"
            
        ;;
        py) mkdir "$target_dir/Python/$student_id" 
            mv "$fullpath" "$target_dir/Python/$student_id/main.py"
            comment_count=$(grep -c "#" "$target_dir/Python/$student_id/main.py")
            function_count=$(grep -c "^def" "$target_dir/Python/$student_id/main.py")
            lang="Python"
            
            if [ "$no_execute" = false ]; then
                for test_file in "$test_dir"/*; do
                    test_file_name=$(basename "$test_file")
                    
                    cp "$test_file" "$target_dir/Python/$student_id/$test_file_name"
                    cd "$target_dir/Python/$student_id"

                    temp_count=$(echo "$test_file_name" | grep -o '[0-9]\+')
                    
                    outputfilename="out$temp_count.txt"

                    rm -f "$outputfilename"
                    rm -f "out$temp_count"
                    rm -f "out0"

                    python3 "main.py" < "$test_file_name" > "$outputfilename"
                    
                    #remove the test file
                    rm "$test_file_name"
                    cd "$current_path"
                done
                match_count=0
                no_match_count=0
                for ans_file in "$ans_dir"/*; do
                    ans_file_name=$(basename "$ans_file")
                    temp_count=$(echo "$ans_file_name" | grep -o '[0-9]\+')
                    # echo "Answer file: $ans_file_name"
                    if diff -q "$ans_file" "$target_dir/Python/$student_id/out$temp_count.txt" > /dev/null; then
                        match_count=$((match_count + 1))
                    else
                        no_match_count=$((no_match_count + 1))
                    fi

                done
            fi


            # echo "Match count: $match_count"
            # echo "No match count: $no_match_count"
        ;;
        java) mkdir "$target_dir/Java/$student_id" 
            mv "$fullpath" "$target_dir/Java/$student_id/Main.java"
            comment_count=$(grep -c "//" "$target_dir/Java/$student_id/Main.java")
            function_count=$(grep -c -P "^\s*(public|private|protected)?\s*(static)?\s*\w+\s+\w+\(.*\)\s*\{" "$target_dir/Java/$student_id/Main.java")

            lang="Java"

        
           


           if [ "$no_execute" = false ]; then
                cd "$target_dir/Java/$student_id"
                javac "Main.java" #2> /dev/null
                cd "$current_path"
                for test_file in "$test_dir"/*; do
                    test_file_name=$(basename "$test_file")
                    
                    cp "$test_file" "$target_dir/Java/$student_id/$test_file_name"
                    cd "$target_dir/Java/$student_id"

                    temp_count=$(echo "$test_file_name" | grep -o '[0-9]\+')
                    
                    outputfilename="out$temp_count.txt"

                    rm -f "$outputfilename"
                    rm -f "out$temp_count"
                    rm -f "out0"

                    java Main < "$test_file_name" > "$outputfilename"
                    
                    #remove the test file
                    rm "$test_file_name"
                    cd "$current_path"
                done

                match_count=0
                no_match_count=0
                for ans_file in "$ans_dir"/*; do
                    ans_file_name=$(basename "$ans_file")
                    temp_count=$(echo "$ans_file_name" | grep -o '[0-9]\+')
                    # echo "Answer file: $ans_file_name"
                    if diff -q "$ans_file" "$target_dir/Java/$student_id/out$temp_count.txt" > /dev/null; then
                        match_count=$((match_count + 1))
                    else
                        no_match_count=$((no_match_count + 1))
                    fi

                done
           fi
            # echo "Match count: $match_count"
            # echo "No match count: $no_match_count"
        ;;



        *) echo "Unsupported file extension: $extention" ;;
    esac

    cd "$current_path"


    variables_towrite="$student_id,$name,$lang"
    if [ "$no_execute" = false ]; then
        variables_towrite="$variables_towrite,$match_count,$no_match_count"
    fi
    if [ "$no_lc" = false ]; then
        variables_towrite="$variables_towrite,$line_count"
    fi
    if [ "$no_cc" = false ]; then
        variables_towrite="$variables_towrite,$comment_count"
    fi
    if [ "$no_fc" = false ]; then
        variables_towrite="$variables_towrite,$function_count"
    fi
    echo "$variables_towrite" >> "$csv_file"

    

    # if [ "$no_execute" = true ]; then
        
    # fi

    # echo "comment count: $comment_count"

    # echo "function_count:$function_count" 

done

    

# echo "--------------------------"

# Step 1: Initialize the columns to remove based on flags








echo "v: $verbose"
echo "no_execute: $no_execute"
echo "no_lc: $no_lc"
echo "no_cc: $no_cc"
echo "no_fc: $no_fc"


# string=hello.world
# echo ${string:2:1}
# echo ${string:2:2}
# echo ${string:2:20}
# echo ${string: -1} # mind the space before - sign
# echo ${string: -4}
# echo ${string:2: -1}
