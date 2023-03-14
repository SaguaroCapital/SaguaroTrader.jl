
"""
Generate a unique UUID
"""
function generate_id()
    return string(UUIDs.uuid1())
end
