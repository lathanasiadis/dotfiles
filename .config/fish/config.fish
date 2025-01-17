function fish_greeting
    # disable greeting
end

function fish_prompt
    # set -l cur_dir (string split '/' --right --max 1 (pwd) | tail -n 1) 
    set -l cur_dir (prompt_pwd -d 3)
    string join '' (set_color green) (whoami) \
                   (set_color blue) '[' (set_color yellow) $cur_dir (set_color blue) ']' \
                   (set_color green) '$ '
end

function dotfiles --wraps git
    git --git-dir $HOME/.dotfiles --work-tree=$HOME $argv
end

function la --wraps eza
    eza -a $argv
end

function ll --wraps eza
    eza --long \
        --group-directories-first \
        --icons \
        --no-user \
        --no-permissions $argv
end 

function lla --wraps eza
    eza --all \
        --long \
        --group-directories-first \
        --icons \
        --no-user \
        --no-permissions $argv
end

source ~/miniconda3/etc/fish/conf.d/conda.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end
