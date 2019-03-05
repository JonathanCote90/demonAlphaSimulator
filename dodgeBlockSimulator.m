%% Demon's Alpha Combat simulator
% This simulator takes two melee combatants that the user designs and pits
% them in an eternity of duels. The number of wins from each side is then
% reported at the end.

%% Combatants details
abilityBonus = [-5 -4 -4 -3 -3 -2 -2 -1 -1 0 0 1 1 2 2 3 3 4 4 5 5]; %Needed for combatants details

% Combatant one

combatants(1).Level = 1;
combatants(1).HD = 10; %ex: Write 8 for d8.
combatants(1).STR = 10;
combatants(1).DEX = 18;
combatants(1).CON = 14;
combatants(1).isFinesse = 1; %0 No, 1 Yes
if combatants(1).isFinesse == 0
    combatants(1).attackStat = abilityBonus(combatants(1).STR);
elseif combatants(1).isFinesse == 1
    combatants(1).attackStat = abilityBonus(combatants(1).DEX);
end

combatants(1).ExtraAttackBonus = 0; %Used for misc

% Damage
combatants(1).NumberOfDamageDice = 1;
combatants(1).ValueOfDamageDice = 6;
combatants(1).LowestCrit = 18; %Lowest values of the crit range

% Dodge
combatants(1).ArmorDodge = 2;
combatants(1).ShieldDodge = 0;

% Block
combatants(1).ArmorBlock = [0 0 0]; % Notation is [Black Blue Orange]
combatants(1).ShieldBlock = [0 0 0];

combatants(1).relianceOnDodge = 1; %0 to 1 prob of dodging

% Combatant two

combatants(2).Level = 1;
combatants(2).HD = 10; %ex: Write 8 for d8.
combatants(2).STR = 10;
combatants(2).DEX = 18;
combatants(2).CON = 14;
combatants(2).isFinesse = 1; %0 No, 1 Yes
if combatants(2).isFinesse == 0
    combatants(2).attackStat = abilityBonus(combatants(2).STR);
elseif combatants(2).isFinesse == 1
    combatants(2).attackStat = abilityBonus(combatants(2).DEX);
end

combatants(2).ExtraAttackBonus = 0; %Used for misc

% Damage
combatants(2).NumberOfDamageDice = 1;
combatants(2).ValueOfDamageDice = 6;
combatants(2).LowestCrit = 18;

% Dodge
combatants(2).ArmorDodge = 2;
combatants(2).ShieldDodge = 0;

% Block
combatants(2).ArmorBlock = [0 0 0]; % Notation is [Black Blue Orange]
combatants(2).ShieldBlock = [0 0 0];

combatants(2).relianceOnDodge = 1; %0 to 1 prob of dodging


%% Constants, dice and other parameters
victoryCount = [0 0];
numberOfItterations = 10000;
victoryByItteration = zeros(numberOfItterations,2);
victoryByItterationPC = zeros(numberOfItterations,2);
isHPRolled = 0; %0 for no, 1 for yes, TODO: average if under

proficiencyBonusByLevel = [2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6];
blackDie = [0 1 1 1 2 2];
blueDie = [1 1 2 2 2 3];
orangeDie = [1 2 2 3 3 4];

%% Pre-fight

for fightNumber = 1:numberOfItterations
%First determine starting HP
if isHPRolled == 0
    combatants(1).MaxHP = combatants(1).HD + abilityBonus(combatants(1).CON) + ((combatants(1).Level-1) * (combatants(1).HD/2 + abilityBonus(combatants(1).CON)));
    combatants(2).MaxHP = combatants(2).HD + abilityBonus(combatants(2).CON) + ((combatants(2).Level-1) * (combatants(2).HD/2 + abilityBonus(combatants(2).CON)));
elseif isHPRolled == 1
    combatants(1).MaxHP = combatants(1).HD + abilityBonus(combatants(1).CON);
    combatants(2).MaxHP = combatants(2).HD + abilityBonus(combatants(2).CON);
    
    if combatants(1).Level > 1
        for c1LevelUp = 1:combatants(1).Level-1
            combatants(1).MaxHP =  combatants(1).MaxHP + ceil(8*rand) +abilityBonus(combatants(1).CON);
        end
    end
    
    if combatants(2).Level > 1
        for c2LevelUp = 1:combatants(2).Level-1
            combatants(2).MaxHP =  combatants(2).MaxHP + ceil(8*rand) +abilityBonus(combatants(1).CON);
        end
    end
    
end

% Roll for initative
combatants(1).Init = ceil(6*rand) + ceil(6*rand) + ceil(6*rand) + abilityBonus(combatants(1).DEX);
combatants(2).Init = ceil(6*rand) + ceil(6*rand) + ceil(6*rand) + abilityBonus(combatants(2).DEX);

%% The Fight
if combatants(1).Init > combatants(2).Init
    starter = 1;
elseif combatants(1).Init < combatants(2).Init
    starter = 2;
elseif combatants(1).Init == combatants(2).Init
    if abilityBonus(combatants(1).DEX) > abilityBonus(combatants(2).DEX)
        starter = 1;
    elseif abilityBonus(combatants(1).DEX) < abilityBonus(combatants(2).DEX)
        starter = 2;
    elseif abilityBonus(combatants(1).DEX) == abilityBonus(combatants(2).DEX)
        starter = ceil(rand*2);
    end
end

combatants(1).currentHP = combatants(1).MaxHP;
combatants(2).currentHP = combatants(2).MaxHP;

currentTurn = starter;
while combatants(1).currentHP > 0 && combatants(2).currentHP > 0
    
    defender = abs(currentTurn-3); %Combatant number of the defender
    natAttackRoll = ceil(6*rand) + ceil(6*rand) + ceil(6*rand);
    attackRoll = natAttackRoll + combatants(currentTurn).attackStat ...
        + proficiencyBonusByLevel(combatants(currentTurn).Level) + combatants(currentTurn).ExtraAttackBonus;

    if natAttackRoll >= combatants(currentTurn).LowestCrit
        totalDamageDice = combatants(currentTurn).NumberOfDamageDice *2; %Computes crit
    else
        totalDamageDice = combatants(currentTurn).NumberOfDamageDice;
    end
        
    %Defender decision
    decisionRandom = rand;
    if decisionRandom > combatants(defender).relianceOnDodge %Then block
        
        armorBlack = rollBlackDice(combatants(defender).ArmorBlock(1),blackDie);
        armorBlue = rollBlueDice(combatants(defender).ArmorBlock(2),blueDie);
        armorOrange = rollOrangeDice(combatants(defender).ArmorBlock(3),orangeDie);
        
        shieldBlack = rollBlackDice(combatants(defender).ShieldBlock(1),blackDie);
        shieldBlue = rollBlueDice(combatants(defender).ShieldBlock(2),blueDie);
        shiledOrange = rollOrangeDice(combatants(defender).ShieldBlock(3),orangeDie);
        
        sumBlocked = armorBlack + armorBlue + armorOrange + shieldBlack + shieldBlue + shiledOrange;
        
        %Damage roll
        damagePreBlock = 0;

        for damageDiceNumber = 1:totalDamageDice
            damagePreBlock = damagePreBlock + ceil(combatants(currentTurn).ValueOfDamageDice * rand);
        end
        
        %Add stat modifier
        damagePreBlock = damagePreBlock + combatants(currentTurn).attackStat;
        
        damagePostBlock = damagePreBlock - sumBlocked;
        if damagePostBlock > 0
            damageDealt = damagePostBlock;
        else
            damageDealt = 0;
        end
        
    else %Then Dodge
        dodgeRoll = ceil(6*rand) + ceil(6*rand) + ceil(6*rand) + combatants(defender).ArmorDodge ...
            + combatants(defender).ShieldDodge + proficiencyBonusByLevel(combatants(defender).Level) ...
            + abilityBonus(combatants(defender).DEX);
        
        damageDealt = 0;
        if dodgeRoll < attackRoll
            for damageDiceNumber = 1:totalDamageDice
                damageDealt = damageDealt + ceil(combatants(currentTurn).ValueOfDamageDice * rand);
            end
            damageDealt = damageDealt + combatants(currentTurn).attackStat; %Add the attack stats damage
        end
        
        
    end
    
    %Remove HP
    combatants(defender).currentHP = combatants(defender).currentHP - damageDealt;
    
    %Change turn
    currentTurn = abs(currentTurn-3);
    
end

if combatants(1).currentHP <= 0
    %sprintf('The winner is Combatant number 2!')
    victoryCount(2) = victoryCount(2)+1;
elseif combatants(2).currentHP <= 0
    %sprintf('The winner is Combatant number 1!')
    victoryCount(1) = victoryCount(1)+1;
else
    sprintf('You messed up! Nobody died!')
end

victoryByItteration(fightNumber,1) = victoryCount(1);
victoryByItteration(fightNumber,2) = victoryCount(2);

victoryByItterationPC(fightNumber,1) = victoryCount(1)/fightNumber;
victoryByItterationPC(fightNumber,2) = victoryCount(2)/fightNumber;

end

figure
plot(victoryByItterationPC(:,1));
xlabel('Fight number')
ylabel('Cumulative victory probability')
title('Victory probability for Combatant 1')

victoryString = ([num2str(victoryByItterationPC(end,1)*100) '% of the time, Combatant 1 wins every time!']);
disp(victoryString);

function blackResult= rollBlackDice(numberOfDice,blackDie)

blackResult = 0;
for rollNumber = 1:numberOfDice
    blackResult = blackResult +  blackDie(ceil(6*rand));
end
end

function blueResult= rollBlueDice(numberOfDice,blueDie)

blueResult = 0;
for rollNumber = 1:numberOfDice
    blueResult = blueResult +  blueDie(ceil(6*rand));
end
end

function orangeResult = rollOrangeDice(numberOfDice,orangeDie)

orangeResult = 0;
for rollNumber = 1:numberOfDice
    orangeResult = orangeResult +  orangeDie(ceil(6*rand));
end
end