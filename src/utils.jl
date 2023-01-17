
"""
Generate a unique UUID
"""
function generate_id()
    return UUIDs.uuid1() |> string
end
