using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }

NewDate<constructor>(year:int, month:int, day:int, hour:int, minute:int, second:int, dayOfWeek:int):=Date:
    Year := year
    Month := month
    Day := day
    Hour := hour
    Minute := minute
    Second := second
    DayOfWeek := dayOfWeek

Date:=class:
    var Year:int
    var Month:int
    var Day:int
    var Hour:int
    var Minute:int
    var Second:int
    var DayOfWeek:int # 1 = Monday, 7 = Sunday

    
TimeManager:=class:
    TimerProp:creative_prop
    var CurrentYear:int = 2024
    var CurrentMonth:int = 5
    var CurrentDay:int = 20
    var CurrentHour:int = 12
    var CurrentMinute:int = 0
    var CurrentSecond:int = 0
    var CurrentDayOfWeek:int = 1 # 1 = Monday, 7 = Sunday
    
    SetDateLoop()<suspends>:void=
        loop:
            # Wait for 1 second
            Sleep(1.0)
            Transform:= TimerProp.GetTransform()
            Translation:=Transform.Translation
            Scale:=Transform.Scale
            Rotation:=Transform.Rotation.GetYawPitchRollDegrees()   
            if:
                NewYear:=Floor[Translation.X+1836.0]
                NewMonth:=Floor[Translation.Y-4307.0]
                NewDay:=Floor[Translation.Z-1000.0]
                NewHour:=Floor[Scale.X]
                NewMinute:=Floor[Scale.Y]
                NewSecond:=Floor[Scale.Z]
                NewDayOfWeek:=Floor[Rotation[0]-19.0]
                set CurrentYear = NewYear
                set CurrentMonth = NewMonth
                set CurrentDay = NewDay
                set CurrentHour = NewHour
                set CurrentMinute = NewMinute
                set CurrentSecond = NewSecond
                set CurrentDayOfWeek = NewDayOfWeek
                

    PrintCurrentDateTime():void=
        Print("Year: {CurrentYear} Month: {CurrentMonth} Day: {CurrentDay}\n Hour: {CurrentHour} Minute: {CurrentMinute} Second: {CurrentSecond} DayOfWeek: {CurrentDayOfWeek}")

    GetNextWeek():Date=
        var newDay:int = CurrentDay + 7
        var newMonth:int = CurrentMonth
        var newYear:int = CurrentYear
        var newDayOfWeek:int = CurrentDayOfWeek + 7

        loop:
            if(newDay <= DaysInMonth(newMonth, newYear)):
                break
            set newDay -= DaysInMonth(newMonth, newYear)
            set newMonth += 1

            if (newMonth > 12):
                set newMonth -= 12
                set newYear += 1

        loop:
            if (newDayOfWeek <= 7):
                break
            set newDayOfWeek -= 7
       

        return NewDate(newYear, newMonth, newDay, CurrentHour, CurrentMinute, CurrentSecond, newDayOfWeek)

    DaysInMonth(month:int, year:int)<transacts>:int=
        if (month = 2):
            if (IsLeapYear(year) = true):
                return 29
            else:
                return 28
        else if (array{4, 6, 9, 11}.Find[month]):
            return 30
        else:
            return 31

    IsLeapYear(year:int)<transacts>:logic=
        if (Mod[year,4] = 0 and (Mod[year, 100 ] <> 0 or Mod[year, 400] = 0)):
            return true
        return false
