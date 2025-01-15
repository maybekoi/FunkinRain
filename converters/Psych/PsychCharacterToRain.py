import json
import os
import shutil

def convert_character(input_file, output_file):
    with open(input_file, 'r') as f:
        char_data = json.load(f)

    hscript_lines = []

    pos_x, pos_y = char_data.get('position', [0, 0])
    cam_x, cam_y = char_data.get('camera_position', [0, 0])
    
    hscript_lines.append(f"positionArray = [{pos_x}, {pos_y}];")
    hscript_lines.append(f"cameraPosition = [{cam_x}, {cam_y}];")
    hscript_lines.append("")

    image_path = char_data['image'].replace('characters/', 'chars/')
    hscript_lines.append(f"loadGraphic('{image_path}');")
    hscript_lines.append("")

    for anim in char_data['animations']:
        name = anim['anim']
        prefix = anim['name']
        fps = anim['fps']
        loop = str(anim['loop']).lower()
        
        if anim['indices']:
            indices_str = ', '.join(str(i) for i in anim['indices'])
            hscript_lines.append(f"addByIndices('{name}', '{prefix}', [{indices_str}], {fps}, {loop});")
        else:
            hscript_lines.append(f"addByPrefix('{name}', '{prefix}', {fps}, {loop});")

    hscript_lines.append("")

    for anim in char_data['animations']:
        name = anim['anim']
        offset_x, offset_y = anim['offsets']
        if offset_x == 0 and offset_y == 0:
            hscript_lines.append(f"addOffset('{name}');")
        else:
            hscript_lines.append(f"addOffset('{name}', {offset_x}, {offset_y});")

    hscript_lines.append("")

    hscript_lines.append("playAnim('idle');")
    hscript_lines.append("")

    hscript_lines.append(f"character.flipX = {str(char_data['flip_x']).lower()};")
    hscript_lines.append("")
    
    sing_duration = char_data.get('sing_duration', 4)
    hscript_lines.append(f"var SING_DURATION = {sing_duration};")
    hscript_lines.append("")

    hscript_lines.append("""function update(elapsed) {
    if (character.animation.curAnim.name.startsWith('sing')) {
        character.holdTimer += elapsed;
    } else {
        character.holdTimer = 0;
    }

    if (character.holdTimer >= Conductor.stepCrochet * SING_DURATION * 0.001) {
        dance();
    }
}""")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write('\n'.join(hscript_lines))

    return char_data['image'] 

def copy_fallback_bf(mod_path):
    bf_script = """positionArray = [0, 0];
cameraPosition = [0, 0];

loadGraphic('chars/BOYFRIEND');

addByPrefix('idle', 'BF idle dance', 24, false);
addByPrefix('singUP', 'BF NOTE UP0', 24, false);
addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

addOffset('idle', -5);
addOffset('singUP', -29, 27);
addOffset('singRIGHT', -38, -7);
addOffset('singLEFT', 12, -6);
addOffset('singDOWN', -10, -50);
addOffset('singUPmiss', -29, 27);
addOffset('singRIGHTmiss', -30, 21);
addOffset('singLEFTmiss', 12, 24);
addOffset('singDOWNmiss', -11, -19);

playAnim('idle');

character.flipX = true;

function update(elapsed) {
    if (character.animation.curAnim.name.startsWith('sing')) {
        character.holdTimer += elapsed;
    } else {
        character.holdTimer = 0;
    }
}

function dance() {
    playAnim('idle');
}"""
    
    bf_path = f"{mod_path}/data/chars/bf.hscript"
    with open(bf_path, 'w') as f:
        f.write(bf_script)
    print("Added fallback bf character")

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
            os.makedirs(f"{mod_path}/data/chars", exist_ok=True)
            os.makedirs(f"{mod_path}/images/chars", exist_ok=True)
        
    copy_fallback_bf(mod_path)

    json_files = [f for f in os.listdir('.') if f.endswith('.json')]
    
    for json_file in json_files:
        character_name = json_file[:-5] 
        output_path = f"{mod_path}/data/chars/{character_name}.hscript"
        
        print(f"Converting {json_file} to {output_path}")
        image_path = convert_character(json_file, output_path)
        
        psych_assets = "../../assets/images"
        if os.path.exists(psych_assets):
            image_name = image_path.split('/')[-1]
            source_png = f"{psych_assets}/{image_path}.png"
            source_xml = f"{psych_assets}/{image_path}.xml"
            
            if os.path.exists(source_png) and os.path.exists(source_xml):
                dest_png = f"{mod_path}/images/{image_path}.png"
                dest_xml = f"{mod_path}/images/{image_path}.xml"
                
                os.makedirs(os.path.dirname(dest_png), exist_ok=True)
                shutil.copy2(source_png, dest_png)
                shutil.copy2(source_xml, dest_xml)
                print(f"Copied assets for {character_name}")
            else:
                print(f"Warning: Assets not found for {character_name}")
    for json_file in json_files:
        print(f"Deleting original file: {json_file}")
        os.remove(json_file)                

if __name__ == "__main__":
    main()
