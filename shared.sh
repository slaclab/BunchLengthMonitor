# Replace "/path/to/directory1" and "/path/to/directory2" with your actual directory paths
dir1="/blenFACETApp/Db"
dir2="/blenApp/Db"

# Use find to list all file names in both directories, including subdirectories
find "$dir1" -type f -exec basename {} \; | sort >files_dir1.txt
find "$dir2" -type f -exec basename {} \; | sort >files_dir2.txt

# Use diff to find common file names
common_files=$(comm -12 files_dir1.txt files_dir2.txt)

# Display the list of common files, including subdirectories
for file in $common_files; do
	find "$dir1" "$dir2" -type f -name "$file" -exec ls -l {} \;
done
