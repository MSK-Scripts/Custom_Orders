Config = {}

Config.Locale = 'de'
Config.Debug = false

Config.Timer = 600000 -- Checks every 10 minutes (600000ms)
Config.repeatMessageAfter = 20000 --gets multiplyed by factor 6! 10000 will be 60000!
Config.AlertDuration = 7000 -- How long the Notification is displayed

-- max and min values for hunger inform alerts

Config.FoodMaxInform = 50
Config.FoodMinInform = 45

Config.FoodMaxError = 15
Config.FoodMinError = 5

-- max and min values for thirst warning alerts (screen effect)

Config.DrinkMaxInform = 55
Config.DrinkMinInform = 45

Config.DrinkMaxError = 15
Config.DrinkMinError = 5


Locales = {
    ['de'] = {
        ['warningThirstAndFood']  = '~r~Ich sollte dringend etwas essen und trinken...',
        ['warningFood']  = '~r~Ich sollte dringend etwas essen...',
        ['warningThirst']  = '~r~Ich sollte dringend etwas trinken...',

        ['errorThirstAndFood']  = '~r~Ich sollte dringend etwas essen und trinken...',
        ['errorFood']  = '~r~Ich habe starken Hunger...',
        ['errorThirst']  = '~r~Ich habe starken Durst...',

        ['informThirstAndFood']  = '~g~Ich bekomme langsam Hunger und Durst',
        ['informFood']  = '~g~Mein Magen knurrt...',
        ['informThirst']  = '~g~Mein Mund fühlt sich etwas trocken an...',
    
        ['noHungerAndNoThirst']  = '~g~Ich bin voll!',
        ['noHunger']  = '~g~Ich bin nicht mehr hungrig...',
        ['noThirst']  = '~g~Ich bin nicht mehr durstig...',
    },
    ['en'] = {
        ['warningThirstAndFood']  = '~r~I should eat and drink something urgently....',
        ['warningFood']  = '~r~I should eat something urgently...',
        ['warningThirst']  = '~r~I should urgently drink something...',

        ['errorThirstAndFood']  = '~r~I should eat and drink something badly....',
        ['errorFood']  = '~r~I am very hungry...',
        ['errorThirst']  = '~r~I have a strong thirst...',

        ['informThirstAndFood']  = '~g~I am getting hungry and thirsty',
        ['informFood']  = '~g~My stomach is growling...',
        ['informThirst']  = '~g~My mouth feels a little dry....',
    
        ['noHungerAndNoThirst']  = '~g~I am full!',
        ['noHunger']  = '~g~I am no longer hungry...',
        ['noThirst']  = '~g~I am no longer thirsty...',
    },
}