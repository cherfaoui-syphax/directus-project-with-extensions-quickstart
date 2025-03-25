# Get the directory where this script is located
$script_directory = $PSScriptRoot

# Run npm i if node_modules does not exist
if (-not (Test-Path "$script_directory\node_modules")) {
    npm i
}

# Parent directory where your subdirectories are located
$parent_directory = "$script_directory\src-extensions"

# Directory where you want to copy the 'dist' folders
$destination_directory = "$script_directory\extensions"

# Loop through each subdirectory in the parent directory
$directories = Get-ChildItem -Path $parent_directory -Directory

foreach ($dir in $directories) {
    $directory = $dir.FullName
    
    # Go to Directory
    Set-Location $directory
    Write-Host $directory

    # Check if node_modules exists, if not run npm i
    if (-not (Test-Path "$directory\node_modules")) {
        npm i
    }
    
    # Build the extension
    npm run build
    
    # Get the name of the subdirectory
    $directory_name = Split-Path $directory -Leaf
    
    # Target Directory name with directus-extension prefix
    $directory_name = "directus-extension-$directory_name"
    
    # Create the destination directory if it doesn't exist
    if (-not (Test-Path "$destination_directory\$directory_name")) {
        New-Item -ItemType Directory -Path "$destination_directory\$directory_name" -Force | Out-Null
    }
    
    # Copy the 'dist' folder to the destination directory
    Copy-Item -Path "$directory\dist" -Destination "$destination_directory\$directory_name" -Recurse -Force
    
    # Copy package.json
    Copy-Item -Path "$directory\package.json" -Destination "$destination_directory\$directory_name" -Force
}

# Check if uploads folder exists if not create it
if (-not (Test-Path "$script_directory\uploads")) {
    New-Item -ItemType Directory -Path "$script_directory\uploads" -Force | Out-Null
}

# Check if .env file exists if not copy .env-sample to .env
if (-not (Test-Path "$script_directory\.env")) {
    Copy-Item -Path "$script_directory\.env-sample" -Destination "$script_directory\.env" -Force
    
    # Define the new value for DB_FILENAME
    $new_db_filename = "$script_directory\data.db"
    
    # Read the content of the .env file
    $envContent = Get-Content "$script_directory\.env" -Raw
    
    # Replace the DB_FILENAME line
    $envContent = $envContent -replace 'DB_FILENAME=".*"', "DB_FILENAME=`"$($new_db_filename.Replace('\', '\\'))`""
    
    # Write the updated content back to the .env file
    Set-Content -Path "$script_directory\.env" -Value $envContent
}

# Change directory to script_directory
Set-Location $script_directory

# Run the index.cjs file to start the server
node index.cjs