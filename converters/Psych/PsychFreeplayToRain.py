import json
import os
import shutil

def convert_freeplay(input_file, output_file):
    with open(input_file, 'r') as f:
        freeplay_data = json.load(f)

    hscript_lines = []

    for song in freeplay_data['songs']:
        song_name = song[0]
        icon_name = song[1]  
        color = song[2]

        display_name = song_name.replace('-', ' ').title()
        
        hscript_lines.append(f'addSong("{song_name}", "{display_name}", "{icon_name}", {color[0]}, "vol1", ["ALL", "{freeplay_data["weekName"]}"]);')

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
            os.makedirs(f"{mod_path}/data/freeplaySongs", exist_ok=True)

    json_files = [f for f in os.listdir('.') if f.endswith('.json')]
    
    for json_file in json_files:
        freeplay_name = json_file[:-5].lower() 
        output_path = f"{mod_path}/data/freeplaySongs/{freeplay_name}.hscript"
        
        print(f"Converting {json_file} to {output_path}")
        convert_freeplay(json_file, output_path)
    for json_file in json_files:
        print(f"Deleting original file: {json_file}")
        os.remove(json_file)        

if __name__ == "__main__":
    main()