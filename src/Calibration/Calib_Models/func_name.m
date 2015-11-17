function name = func_name (method)

if method >= 3 && method <= 10
    name = 'Geometric Non-Central Model';
elseif method >= 1 && method <= 2
    name = 'Geometric Central Model';
elseif method == 11
    name = 'Scaramuzza with new initialization';
elseif method == 12
    name = 'Mei Model';
elseif method == 14
    name = 'Centered Model';
elseif method == 16
    name = 'Geyer Model';
elseif method == 17
    name = 'Scaramuzza';
end
