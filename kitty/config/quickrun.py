import re
from typing import List
from kitty.boss import Boss

from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut


def is_window_vim(window, vim_id):
    fp = window.child.foreground_processes
    return any(re.search(vim_id, p['cmdline'][0] if len(p['cmdline']) else '', re.I) for p in fp)


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)


def main(args: List[str]) -> str:
    pass

@result_handler(no_ui=True)
def handle_result(args: List[str], result: str, target_window_id: int, boss: Boss) -> None:
    key_mapping = "ctrl+`"
    vim_id = args[2] if len(args) > 2 else "n?vim"

    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return
    if is_window_vim(window, vim_id):
        pass
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    else:
        w = boss.window_id_map.get(target_window_id)
        with open("/home/jyh/.cache/quickrun/last-command", "r") as fp:
            command = fp.readline().rstrip("\n")
            cwd = fp.readline().rstrip("\n")
        window_cwd = w.cwd_of_child
        if (cwd != window_cwd):
            boss.call_remote_control(w, ('send-text', f"--match=id:{w.id}", "cd " + cwd + "\n"))
        # boss.call_remote_control(w, ('action', 'clear_terminal', 'scroll', 'active', f'--match=id:{w.id}'))
        boss.call_remote_control(w, ('send-text', f'--match=id:{w.id}', command + "\n"))
