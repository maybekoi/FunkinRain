import json
import os
import shutil

def convert_week(input_file, output_file):
    with open(input_file, 'r') as f:
        week_data = json.load(f)

    hscript_lines = []

    songs = [song[0] for song in week_data['songs']]
    songs_str = ', '.join(f"'{song}'" for song in songs)
    hscript_lines.append(f"songs = [{songs_str}];")

    chars_str = ', '.join(f"'{char}'" if char else "''" for char in week_data['weekCharacters'])
    hscript_lines.append(f"weekCharacters = [{chars_str}];")

    hscript_lines.append(f"weekName = \"{week_data['storyName']}\";")

    hscript_lines.append("stage = \"stage\";")

    difficulties = [diff.strip() for diff in week_data['difficulties'].split(',')]
    diffs_str = ', '.join(f"\"{diff.lower()}\"" for diff in difficulties)
    hscript_lines.append(f"difficulties = [{diffs_str}];")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write('\n'.join(hscript_lines))

def main():
    mod_name = "PsychConverted"
    mod_path = f"../../mods/{mod_name}"
    
    if os.path.exists(mod_path):
        print(f"Using existing {mod_name} mod...")
    else:
        template_path = "../../mods/Template"
        if os.path.exists(template_path):
            print(f"Creating new {mod_name} mod from template...")
            shutil.copytree(template_path, mod_path)
        else:
            print("Warning: Template mod not found, creating basic structure")
            os.makedirs(mod_path, exist_ok=True)
            os.makedirs(f"{mod_path}/data/weeks", exist_ok=True)

    json_files = [f for f in os.listdir('.') if f.endswith('.json')]
    
    for json_file in json_files:
        week_name = json_file[:-5]  
        output_path = f"{mod_path}/data/weeks/{week_name}.hscript"
        
        print(f"Converting {json_file} to {output_path}")
        convert_week(json_file, output_path)
    for json_file in json_files:
        print(f"Deleting original file: {json_file}")
        os.remove(json_file)

if __name__ == "__main__":
    main()
