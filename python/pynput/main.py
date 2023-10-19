from pynput import keyboard


def on_press(key):
    try:
        print('Key {0} pressed.'.format(key.char))
    except AttributeError:
        print('Special key {0} pressed.'.format(key))


def on_release(key):
    print('Key {0} released.'.format(key))
    if key == keyboard.Key.esc:
        # 如果按下了 ESC 键，则停止监听
        return False


# 创建监听器
listener = keyboard.Listener(
    on_press=on_press,
    on_release=on_release)
# 开始监听
listener.start()
# 等待监听器停止（按下 ESC 键）
listener.join()
