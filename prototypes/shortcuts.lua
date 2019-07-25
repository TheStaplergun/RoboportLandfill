local Data = require('__stdlib__/stdlib/data/data')

Data {
    type = 'shortcut',
    name = 'roboport-landfill-toggle-radius',
    action = 'lua',
    toggleable = true,
    icon = {
        filename = '__RoboportLandfill__/graphics/shortcuts/roboport-construction-radius.png',
        priority = 'extra-high-no-scale',
        size = 32,
        scale = 1,
        flags = {'icon'}
    },
    disabled_icon = {
        filename = '__RoboportLandfill__/graphics/shortcuts/roboport-logistic-radius.png',
        priority = 'extra-high-no-scale',
        size = 32,
        scale = 1,
        flags = {'icon'}
    },
}
Data {
    type = 'shortcut',
    name = 'roboport-landfill-toggle-on-off',
    action = 'lua',
    toggleable = true,
    icon = {
        filename = '__RoboportLandfill__/graphics/shortcuts/automatic-landfill.png',
        priority = 'extra-high-no-scale',
        size = 32,
        scale = 1,
        flags = {'icon'}
    },
    disabled_icon = {
        filename = '__RoboportLandfill__/graphics/shortcuts/no-automatic-landfill.png',
        priority = 'extra-high-no-scale',
        size = 32,
        scale = 1,
        flags = {'icon'}
    },
}
