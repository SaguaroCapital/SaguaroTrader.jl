using Dates
using Base.Filesystem

function process_directory_for_llm_improved(src_dir::String, output_file::String)
    open(output_file, "w") do io
        println(io, "# Source Code from: $src_dir")
        println(io, "# Generated on: $(Dates.now())")
        println(io, "# ---------------------------------------------------\n")

        for (root, dirs, files) in walkdir(src_dir)
            sort!(files)
            for file in files
                filepath = joinpath(root, file)
                relative_path = relpath(filepath, src_dir)
                println(io, "## File: $relative_path\n")

                try
                    content = read(filepath, String)
                    language_hint = lowercase(splitext(file)[end][2:end]) # Try to get language from extension
                    if !isempty(language_hint) &&
                        language_hint in ["jl", "py", "js", "java", "c", "cpp", "go", "rs"] # Add more as needed
                        println(io, "```$(language_hint)")
                    else
                        println(io, "```") # Generic code block
                    end
                    println(io, content)
                    println(io, "```\n")
                catch e
                    println(stderr, "Error reading file: $filepath - $e")
                    println(io, "```")
                    println(io, "# Error reading file: $relative_path - $e")
                    println(io, "```\n")
                end
            end
        end
    end
    return println(
        "Successfully processed directory '$src_dir' and saved to '$output_file'"
    )
end

if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) != 2
        println("Usage: julia script_name.jl <source_directory> <output_file>")
        exit(1)
    end

    src_dir = ARGS[1]
    output_file = ARGS[2]

    if !isdir(src_dir)
        println("Error: Source directory '$src_dir' does not exist.")
        exit(1)
    end

    process_directory_for_llm_improved(src_dir, output_file)
end
