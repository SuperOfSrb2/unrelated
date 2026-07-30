local MegaDummy, super = Class(Encounter)

function MegaDummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The dummy is here."

    local songs = {
        "battle",
        "battle2",
        "battle3",
        "battle_vapor",
        "boxing_boss",
        "checkers",
        "eram",
        "fromnowon",
        "gerson",
        "gigasize",
        "jackenstein",
        "joker",
        "kingboss",
        "knight",
        "lancerfight",
        "megalovaniasrs",
        "mike",
        "queen_boss",
        "rouxls_battle",
        "ruderbuster",
        "shadowblazer",
        "smartrace",
        "spamton",
        "spamtonneo",
        "theyslashthem",
        "titan",
        "titan_spawn",
        "tvtime",
        "vs_susie",
        "amalgam",
        "battle_fire",
        "battle_water",
        "battle_tem",
        "battle_snow",
        "battle_ruins",
        "battle_ut",
        "battle2_ut",
        "battle3_fromsomewhere",
        "toriel",
        "breakcore",
        "meltdown",
        "ufdogsong",
        "dummy",
        "final_battle",
        "finale",
        "ghostfight",
        "royalguard",
        "mettaton_ex",
        "metalcrusher",
        "madmewmew",
        "news_fight",
        "notenough",
        "bonetrousle",
        "spiderdance",
        "battle_genesis",
        "TOBES_STOLE_THIS_SONG",
        "alexyard",
        "mirrorboss",
        "mirrorboss2",
        "asgore",
        "underlab",
        "undynex",
        "asriel1",
        "asriel2",
        "megalovania",
        "pyrus",
        "pyrustrailer",
        "megalovaniaremix",
        "bereavement",
        "bonetrousleremix",
        "battle_core",
        "battle_yellow",
        "asgore_yellow",
        "power_of_neo",
        "supercosplayingastobesstealingsongs",
        "bestintroevar",
        "boss2",
        "cookiesandcream",
        "bigarms",
        "THISWILLBERELEVANTTODELTARUNE",
        "ufsans",
        "songofunknownorigin",
        "flowey_dt",
        "floraldefiance_odd",
        "floraldefiance_j",
        "floraldefiance_yellow",
        "shattereddreams",
        "kingofnothing",
        "nobonesaboutit",
        "floraldefiance",
        "apprehension_yellow",
        "battle_snowdin",
        "dalvbattle_yellow",
        "danza_battle_yellow",
        "deal_em_out_yellow",
        "decibat_yellow",
        "final_stand",
        "bff",
        "enemyretreating",
        "guardener",
        "guns_blazing",
        "end_of_the_line_",
        "battle_desert",
        "martlet",
        "mothersloveold",
        "motherslove1",
        "motherslove2",
        "motherslove3",
        "battle_ex",
        "battle_west",
        "remedy",
        "showdown",
        "macrofroggit",
        "trampled_flowers",
        "trial_by_fury",
        "trial_by_fury_2",
        "unforgiving",
        "retribution"
    }


    rng = love.math.random(1, #songs)
    self.music = "testbattle/"..songs[rng]
    -- Enables the purple grid battle background
    self.background = true

    -- Add the dummy enemy to the encounter
    self:addEnemy("megadummy", 2*270/3 + 23, 0 + 70)
    self:addEnemy("megadummy", 4*270/3 + 23, 25 + 70)
    --self:addEnemy("dummy")
    --self:addEnemy("dummy")

    --- Uncomment this line to add another!
    --self:addEnemy("dummy")
end

return MegaDummy