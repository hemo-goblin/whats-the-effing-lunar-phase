module LunarPhaseHelper

  # The Julian Date for January 6, 2000. A new moon occurred on this day and it's as good of a base as any.
  BASE_NEW_MOON_DATE = 2451549.5

  # The length of a lunar cycle, in Julian time.
  JULIAN_LUNAR_CYCLE = 29.530588853

  ##
  # Calculates the Julian Date from the given Gregorian Date and time.
  # Params:
  # +month+:: The month (1-12) of the date on which to calculate the Julian Date.
  # +day+:: The day (1-31) of the date on which to calculate the Julian Date.
  # +year+:: The year (> 0) of the date on which to calculate the Julian Date.
  # +hour+:: Integer whose value is the hour (0-23) of the time on which to calculate the Julian Date.
  # +minute+:: Integer whose value is the minute (0-59) of the time on which to calculate the Julian Date.
  # +second+:: Integer whose value is the second (0-59) of the time on which to calculate the Julian Date.
  # Returns the Julian Date
  ##
  def gregorianDateAndTimeToJulianDate(month, day, year, hour, minute, second)
    julianDateAtTimeOnJulianDay(gregorianDateToJulianDayNumber(month, day, year),hour, minute, second)
  end

  ##
  # Calculates the Julian Day Number from the given Gregorian Date
  # Params:
  # +month+:: The month (1-12) of the date on which to calculate the Julian Date.
  # +day+:: The day (1-31) of the date on which to calculate the Julian Date.
  # +year+:: The year (> 0) of the date on which to calculate the Julian Date.
  # Returns the Julian Day Number
  ##
  def gregorianDateToJulianDayNumber(month, day, year)
    # The following variable evaluates to 1 if the supplied month is January or February.
    isJanOrFeb = (14 - month) / 12

    # Number of years since March 1, -4800, which is just apparently how you do this according to any resources
    # I can find. The Julian Epoch isn't until Jan 1, -4714, but okay. I'm going to refer to March 1, -4800 as the
    # "anchor" from here on out. I mean that's basically what it is.
    yearsSinceAnchor = year + 4800 - isJanOrFeb

    # Number of months since last March.
    monthsSinceMarch = month + (12 * isJanOrFeb) - 3

    # Number of days since last March 1.
    # According to Wikipedia:
    # "(153m+2)/5 gives the number of days since March 1 and comes from the
    # repetition of days in the month from March in groups of five."
    daysSinceMarchFirst = ((153 * monthsSinceMarch) + 2) / 5

    leapDays = (yearsSinceAnchor / 4) - (yearsSinceAnchor / 100) + (yearsSinceAnchor / 400)

    # The Julian Day Number
    # The subtraction of 32045 corrects for the number of days between March 1, -4800 and January 1, -4714
    # Ruby automatically returns the result of this statement.
    day + daysSinceMarchFirst + (356 * yearsSinceAnchor) + leapDays - 32045
  end

  ##
  # Calculates the Julian Date from the Julian Day Number and the given time.
  # Params:
  # +julianDay+:: The Julian Day Number on which to calculate the Julian Date.
  # +hour+:: The hour (0-23) of the time on which to calculate the Julian Date.
  # +minute+:: The minute (0-59) of the time on which to calculate the Julian Date.
  # +second+:: The second (0-59) of the time on which to calculate the Julian Date.
  #
  # Returns the Julian Date
  ##
  def julianDateAtTimeOnJulianDay(julianDayNumber, hour, minute, second)
    # The Julian Date value is the Julian Day Number, plus the fractions of a day accounted for by the
    # given hour, minute, and second; A day has 24, 1440, and 86400, respectively.
    julianDayNumber + hour.fdiv(24) + minute.fdiv(1440) + second.fdiv(86400)
  end

  ##
  # Determines tonight's lunar phase from the difference between the Julian Date of tonight at midnight GMT and the
  # Julian Date at midnight GMT on a day that a New Moon has occurred in the past, BASE_NEW_MOON_DATE
  #
  # Returns the lunar phase. (0-7)
  ##
  def lunarPhaseTonight
    # The Julian Date at midnight GMT tonight. (i.e. Tomorrow)
    julianDateTonight = gregorianDateAndTimeToJulianDate(Time.now.month, (Time.now.day + 1), Time.now.year, 12, 0, 0)

    # Get the lunar phase from said date
    lunarPhaseFromJulianDate(julianDateTonight)
  end

  ##
  # Determines the lunar phase on a particular Julian Date
  # Params:
  # +julianDate+:: The Julian Date to find the lunar phase for.
  #
  # Returns the lunar phase. (0-7)
  ##
  def lunarPhaseFromJulianDate(julianDate)
    # The difference between the Julian Date tonight and the base
    julianDifference = julianDate - BASE_NEW_MOON_DATE

    # If the difference is less than zero (meaning it is somehow before January 6, 2000) then just add the length of
    # a lunar cycle, because the negative number is just the amount of Julian time before the next new moon.
    if julianDifference < 0
      julianDifference += JULIAN_LUNAR_CYCLE
    end

    # The "phase date", as I call it, is the modulus of the difference between the given date and the base new moon
    # date (adjusted if the given date predates January 6, 2000) by the length of a lunar cycle in Julian time.
    # We use this phaseDate to see where we fall in the cycle and determine the moon's phase.
    phaseDate = julianDifference % JULIAN_LUNAR_CYCLE

    # There are eight different phases. However, the moon could appear to be new at the beginning or end of the lunar
    # cycle. Therefore, you will notice there are two 0 cases. They are equal in size and, combined, are equal
    # in size to the other phases.
    if phaseDate < 1.84566
      lunarPhase = 0
    elsif phaseDate < 5.53699
      lunarPhase = 1
    elsif phaseDate < 9.22831
      lunarPhase = 2
    elsif phaseDate < 12.91963
      lunarPhase = 3
    elsif phaseDate < 16.61096
      lunarPhase = 4
    elsif phaseDate < 20.30228
      lunarPhase = 5
    elsif phaseDate < 23.99361
      lunarPhase = 6
    elsif phaseDate < 27.86493
      lunarPhase = 7
    else
      lunarPhase = 8
    end

    # Return the lunar phase.
    lunarPhase
  end

  ##
  # Gets the name of the given lunar phase from its ID
  # Params:
  # +phaseID+:: The ID (0-7) of the lunar phase
  #
  # Returns the name of the given lunar phase
  ##
  def getLunarPhaseNameFromID(phaseID)
    case phaseID
      when 0
        'New Moon'
      when 1
        'Waxing Crescent Moon'
      when 2
        'First Quarter Moon'
      when 3
        'Waxing Gibbous Moon'
      when 4
        'Full Moon'
      when 5
        'Waning Gibbous Moon'
      when 6
        'Last Quarter Moon'
      when 7
        'Waning Crescent Moon'
      else
        'New Moon'
    end
  end

    ##
    # Gets the name of the icon for the given lunar phase from its ID
    # Params:
    # +phaseID+:: The ID (0-7) of the lunar phase
    #
    # Returns the name of the icon of the given lunar phase
    ##
    def getLunarIconNameFromID(phaseID)
      case phaseID
        when 0
          'newMoon.svg'
        when 1
          'waxingCrescent.svg'
        when 2
          'firstQuarter.svg'
        when 3
          'waxingGibbous.svg'
        when 4
          'fullMoon.svg'
        when 5
          'waningGibbous.svg'
        when 6
          'lastQuarter.svg'
        when 7
          'waningCrescent.svg'
        else
          'newMoon.svg'
      end
    end

  ##
  # Retrieves a random exclamation.
  ##
  def getRandomExclamation
    getRandomLineOfFile('exclamations.txt')
  end

  ##
  # Retrieves a random quote.
  ##
  def getRandomQuote
    getRandomLineOfFile('quotes.txt')
  end

  ##
  # Retrieves a random line from the selected file.
  # Params:
  # +filename+:: The name of the file to get a random line from
  #
  # Returns a random line from the file specified at filename.
  ##
  def getRandomLineOfFile(filename)
    currentLine = nil
    File.foreach(Rails.root.join('app', 'assets', filename)).each_with_index do | line, number |
      currentLine = line if rand < 1.0/(number+1)
    end
    currentLine
  end
end
