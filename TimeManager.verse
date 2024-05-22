using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }

NewDate<constructor>(year:int, month:int, day:int, hour:int, minute:int, second:int, dayOfWeek:int)<transacts>:=Date:
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
    var CurrentDate:Date = Date{Year:=2024, Month:=5, Day:=20, Hour:=12, Minute:=0, Second:=0, DayOfWeek:=1} # 1 = Monday


    SetDateLoop()<suspends>:void=
        loop:
            # Wait for 1 second
            Sleep(1.0)
            Transform:= TimerProp.GetTransform()
            Translation:=Transform.Translation
            Scale:=Transform.Scale
            Rotation:=Transform.Rotation.GetYawPitchRollDegrees()   
            if:
                NewYear:=Floor[Translation.X]
                NewMonth:=Floor[Translation.Y]
                NewDay:=Floor[Translation.Z]
                NewHour:=Floor[Scale.X]
                NewMinute:=Floor[Scale.Y]
                NewSecond:=Floor[Scale.Z]
                NewDayOfWeek:=Floor[Rotation[0]]
                set CurrentDate = NewDate(NewYear, NewMonth, NewDay, NewHour, NewMinute, NewSecond, NewDayOfWeek)
                
                

(date:Date).PrintCurrentDateTime():void=
        Print("Year: {date.Year} Month: {date.Month} Day: {date.Day}\n Hour: {date.Hour} Minute: {date.Minute} Second: {date.Second} DayOfWeek: {date.DayOfWeek}")

    

(date:Date).AddTime(S:string, ?Years:int=0, ?Months:int=0, ?Days:int=0, ?Hours:int=0, ?Minutes:int=0, ?Seconds:int=0):Date=
        var newYear:int = date.Year + Years
        var newMonth:int = date.Month + Months
        var newDay:int = date.Day + Days
        var newHour:int = date.Hour + Hours
        var newMinute:int = date.Minute + Minutes
        var newSecond:int = date.Second + Seconds
        var newDayOfWeek:int = date.DayOfWeek + Days

        # Normalize the date and time
        loop:
            if(newSecond < 60):
                break
            set newSecond -= 60
            set newMinute += 1
        loop:
            if(newMinute < 60):
                break
            set newMinute -= 60
            set newHour += 1

        loop:
            if(newHour < 24):
                break
            set newHour -= 24
            set newDay += 1

        loop:
            if(newDay <= date.DaysInMonth()):
                break
            set newDay -= date.DaysInMonth()
            set newMonth += 1

            if (newMonth > 12):
                set newMonth -= 12
                set newYear += 1

        loop:
            if(newDayOfWeek <= 7):
                break
            set newDayOfWeek -= 7

        return NewDate(newYear, newMonth, newDay, newHour, newMinute, newSecond, newDayOfWeek)


    
(date:Date).GetNextWeek():Date=
        var newDay:int = date.Day + 7
        var newMonth:int = date.Month
        var newYear:int = date.Year
        var newDayOfWeek:int = date.DayOfWeek + 7

        loop:
            if(newDay <= date.DaysInMonth()):
                break
            set newDay -= date.DaysInMonth()
            set newMonth += 1

            if (newMonth > 12):
                set newMonth -= 12
                set newYear += 1

        loop:
            if (newDayOfWeek <= 7):
                break
            set newDayOfWeek -= 7
       

        return NewDate(newYear, newMonth, newDay, date.Hour, date.Minute, date.Second, newDayOfWeek)

(date:Date).DaysInMonth()<transacts>:int=
        if (date.Month = 2):
            if (date.IsLeapYear[]):
                return 29
            else:
                return 28
        else if (array{4, 6, 9, 11}.Find[date.Month]):
            return 30
        else:
            return 31

(date:Date).IsLeapYear()<transacts><decides>:void=
    var IsLeap:logic=false
    if (Mod[date.Year,4] = 0 and (Mod[date.Year, 100 ] <> 0 or Mod[date.Year, 400] = 0)):
        set IsLeap = true
    IsLeap = true

(date: Date).TimeUntil(target: Date)<transacts>: tuple(int, int, int, int) =
    var currentTimestamp: int = date.ToTimestamp()
    var targetTimestamp: int = target.ToTimestamp()
    var diff: int = targetTimestamp - currentTimestamp

    if(var days: int = Floor(diff / (24 * 3600))):
        set diff -= days * 24 * 3600

        if(var hours: int = Floor(diff / 3600)):
            set diff -= hours * 3600

            if(var minutes: int = Floor(diff / 60)):
                var seconds: int = diff - (minutes * 60)

                return (days, hours, minutes, seconds)
    return (0, 0, 0, 0)

(date: Date).ToTimestamp()<transacts>: int =
    return ((date.Year * 365 + date.Month * 30 + date.Day) * 24 + date.Hour) * 3600 + date.Minute * 60 + date.Second

(date: Date).GenerateDailySeed(): int =
    return date.Year * 10000 + date.Month * 100 + date.Day

(date: Date).GenerateWeeklySeed(): int =
    var firstDayOfWeek: Date = date.GetFirstDayOfWeek()
    return firstDayOfWeek.Year * 10000 + firstDayOfWeek.Month * 100 + firstDayOfWeek.Day

(date: Date).GetFirstDayOfWeek(): Date =
    var daysToSubtract: int = date.DayOfWeek - 1
    var firstDayOfWeek: Date = NewDate(date.Year, date.Month, date.Day - daysToSubtract, 0, 0, 0, 1)
    return firstDayOfWeek

(date: Date).IsMoreThanAWeekSince(startDate: Date)<transacts>: logic =
    days := startDate.TimeUntil(date)(0)
    if(days >= 7):
        return true
    return false

