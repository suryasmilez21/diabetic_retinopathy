# Import the necessary packages
using CSV
using DataFrames

# Specify the path to your CSV file
# (Can be a relative path like this, or an absolute path like "/home/user/data/my_data.csv")
filepath = "diabetic_retinopathy.csv"

# try
    # Read the CSV file into a DataFrame
    # CSV.read automatically handles headers and tries to infer data types.
    # It also recognizes standard missing values (like the empty field for Charlie).
    df = CSV.read(filepath, DataFrame)

    # Print the DataFrame to see the contents
    println("Successfully read CSV into DataFrame:")
    println(df.Hornerin)  #df.Clinical_Group  #only reads that column

    # You can now work with the DataFrame 'df'
    # println("\nAccessing data:")
    # println("Value for Bob: ", df[df.Name .== "Bob", :Value][1]) # Example access 
    # println("Data Types of columns:")
    # println(eltype.(eachcol(df))) # Show inferred types per column #ctrl+forward slash to make it as a command

# catch e
#     println("Error reading CSV file: ", filepath)
#     showerror(stdout, e)
#     println()
# end
using CSV
using DataFrames
using Missings
# Load the dataset
df = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Display basic information
println("Initial DataFrame Info:")
println(names(df))  # Column names
println(size(df))   # Dimensions
println(describe(df))  # Summary of columns
# Replace "Nil" and potential "NaN" strings with missing across all columns
for col in names(df)
    df[!, col] = map(x -> (x == "Nil" || x == "NaN" || x === nothing) ? missing : x, df[!, col])
end

# Check for "-" in columns other than Albuminuria to identify if it needs special handling
println("\nColumns containing '-' (excluding Albuminuria):")
for col in names(df)
    if col != "Albuminuria"
        count_dash = sum(x -> !ismissing(x) && x == "-", df[!, col])
        if count_dash > 0
            println("$col: $count_dash occurrences of '-'")
        end
    end
end
# Check for missing values
println("\nMissing Values per Column (after Nil/NaN handling):")
for col in names(df)
    println("$col: $(sum(ismissing, df[!, col]))")
end
# Remove rows with more than 50% missing values
threshold = 0.5 * length(names(df))
df = df[completecases(df[:, [col for col in names(df) if sum(ismissing, df[!, col]) / nrow(df) < 0.5]]), :]

# Convert categorical columns to appropriate types
df[!, :Clinical_Group] = convert(Vector{String}, coalesce.(df[!, :Clinical_Group], "Unknown"))
df[!, :Gender] = convert(Vector{String}, coalesce.(df[!, :Gender], "Unknown"))

# Handle Albuminuria: map to ordinal values (Neg, -, 1+, 2+, 3+, 4+)
albuminuria_map = Dict("Neg" => 0, "-" => 0, "1+" => 1, "2+" => 2, "3+" => 3, "4+" => 4)
df[!, :Albuminuria] = [ismissing(x) ? missing : get(albuminuria_map, x, 0) for x in df[!, :Albuminuria]]
# Save cleaned DataFrame for inspection
CSV.write("cleaned_diabetic_retinopathy_updated.csv", df)
println("\nCleaned DataFrame saved as 'cleaned_diabetic_retinopathy_updated.csv'.")
println("Preview of cleaned DataFrame:")
println(first(df, 5))
