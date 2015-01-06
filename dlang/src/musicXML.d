/**
 * Do not modify this automatically generated file!!!
 * 
 * Generated from "MusicXML".
 * Portions copyright (C) 2015 Josh Netterfield.
 * Part of the ripieno-musicxml project to make MusicXML more accessible.
 * 
 * MusicXML™ Version 3.0
 * 
 * Copyright © 2004-2011 MakeMusic, Inc.
 * http://www.makemusic.com/
 * 
 * This MusicXML™ work is being provided by the copyright
 * holder under the MusicXML Public License Version 3.0,
 * available from:
 * 
 * http://www.musicxml.org/dtds/license.html
 * This file contains multiple DTDs.
 */
import xml;
import libxml2.tree;
import std.exception;
import std.stdio;
import std.conv;
import std.variant;

import vibejson.json;
import core.internal.hash;
import std.regex;
import std.string;

T popFront(T)(T t) {
    return t[1..$];
}

export string getString(T)(T p, bool required) {
    try {
        auto children = p.children;
        enforce(children, new NoElementFound);
        auto child = children.first!(xmlElementType.XML_TEXT_NODE);
        enforce(child && child.content, new NoElementFound);

        return child.content.toString.idup;
    } catch(NoElementFound nef) {
        enforce(!required, nef);
        return "";
    }
}

export float getNumber(T)(T p, bool required) {
    return getString(p, required).to!float;
}

auto ctr = ctRegex!(r"[- ](.)", "g");
R toCamelCase(R)(R s) {
    R camelHelper(Captures!(R) m) {
        return m.hit.length == 2 ? m.hit[1].toUpper.to!R : R.init;
    }
    R result = s.replaceAll!camelHelper(ctr).strip;
    return result.length ? result : "";
}

R ToPascalCase(R)(R s) {
    R camel = s.toCamelCase;
    if (camel.length) {
        return camel[0].toUpper.to!R ~ camel[1..$];
    }
    return R.init;
}


export class CalendarDate {
    mixin ICalendarDate;
    this(xmlNodePtr node) {
        string text = getString(node, true);
        if (text.length < 10) {
            return;
        }
        year = text[0..4].to!float;
        month = text[5..7].to!float;
        day = text[8..10].to!float;
    }
}

class AccOrText {
    AccidentalText acc;
    DisplayText text;
    bool isAcc;
}

alias TextArray = AccOrText[];
alias EncodingDate = CalendarDate;

export class NoteheadText {
    mixin INoteheadText;
    this(xmlNodePtr node) {
        auto ch = node;
        // TODO
        // text = TextArray(ch);   
    }
}

export class PartNameDisplay {
    mixin INoteheadText;
    this(xmlNodePtr node) {
        auto ch = node;
        // TODO
        // text = TextArray(ch);   
    }
}

export class PartAbbreviationDisplay {
    mixin INoteheadText;
    this(xmlNodePtr node) {
        auto ch = node;
        // TODO
        // text = TextArray(ch);   
    }
}

export class Measure {
    mixin IMeasure;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
             if (ch.name.toString == "part") {
                 // Note: assumes valid document, and so first and only property is id.
                 parts[getString(ch.properties, true)] ~= Part(ch) ;
             }
        }
        bool foundImplicit = false;
        bool foundNonControlling = false;
        for (auto ch = node.properties; ch; ch = ch.next) {
             if (ch.name.toString == "number") {
                 number_ = getString(ch, true);
             }
             if (ch.name.toString == "implicit") {
                 implicit = getYesNo(ch, true);
                 foundImplicit = true;
             }
             if (ch.name.toString == "width") {
                 width = getNumber(ch, true);
             }
             if (ch.name.toString == "non-controlling") {
                 nonControlling = getYesNo(ch, true);
                 foundNonControlling = true;
             }
        }
        if (!foundImplicit) {
            implicit = false;
        }
        if (!foundNonControlling) {
            nonControlling = false;
        }
    }
    Json toJson() {
        import measureToJson : measureToJson;
        return measureToJson(this);
    }
    static Measure fromJson(Json t) {
        assert(false, "Not implemented");
    }
}

/**
 * The yes-no entity is used for boolean-like attributes.
 */
alias YesNo = bool;

bool getYesNo(T)(T p, bool required) {
    string s = getString(p, true);
    if (s == "no") {
        return false;
    }
    if (s == "yes") {
        return true;
    }
    assert(!required, "Not reached");
    return false;
}

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */

/**
 * The tuning-step, tuning-alter, and tuning-octave elements
 * are represented like the step, alter, and octave elements,
 * with different names to reflect their different function.
 * They are used in the staff-tuning and accord elements.
 */


alias Voice = float;

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */

/**
 * A string describing a software.
 */

/**
 * 
 * Encoding contains information about who did the digital
 * encoding, when, with what software, and in what aspects.
 * Standard type values for the encoder element are music,
 * words, and arrangement, but other types may be used. The
 * type attribute is only needed when there are multiple
 * encoder elements.
 * 
 * The supports element indicates if the encoding supports
 * a particular MusicXML element. This is recommended for
 * elements like beam, stem, and accidental, where the
 * absence of an element is ambiguous if you do not know
 * if the encoding supports that element. For Version 2.0,
 * the supports element is expanded to allow programs to
 * indicate support for particular attributes or particular
 * values. This lets applications communicate, for example,
 * that all system and/or page breaks are contained in the
 * MusicXML file.
 */

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */
alias BeatType = float;

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */

/**
 * Instruments are only used if more than one instrument is
 * represented in the part (e.g., oboe I and II where they
 * play together most of the time). If absent, a value of 1
 * is assumed.
 */

/**
 * Clefs are represented by the sign, line, and
 * clef-octave-change elements. Sign values include G, F, C,
 * percussion, TAB, jianpu, and none. Line numbers are
 * counted from the bottom of the staff. Standard values are
 * 2 for the G sign (treble clef), 4 for the F sign (bass clef),
 * 3 for the C sign (alto clef) and 5 for TAB (on a 6-line
 * staff). The clef-octave-change element is used for
 * transposing clefs (e.g., a treble clef for tenors would
 * have a clef-octave-change value of -1). The optional
 * number attribute refers to staff numbers within the part,
 * from top to bottom on the system. A value of 1 is
 * assumed if not present.
 * 
 * The jianpu sign indicates that the music that follows
 * should be in jianpu numbered notation, just as the TAB
 * sign indicates that the music that follows should be in
 * tablature notation. Unlike TAB, a jianpu sign does not
 * correspond to a visual clef notation.
 * 
 * Sometimes clefs are added to the staff in non-standard
 * line positions, either to indicate cue passages, or when
 * there are multiple clefs present simultaneously on one
 * staff. In this situation, the additional attribute is set to
 * "yes" and the line value is ignored. The size attribute
 * is used for clefs where the additional attribute is "yes".
 * It is typically used to indicate cue clefs.
 * 
 * Sometimes clefs at the start of a measure need to appear
 * after the barline rather than before, as for cues or for
 * use after a repeated section. The after-barline attribute
 * is set to "yes" in this situation. The attribute is ignored
 * for mid-measure clefs.
 * 
 * Clefs appear at the start of each system unless the
 * print-object attribute has been set to "no" or the
 * additional attribute has been set to "yes".
 */

/**
 * Clefs are represented by the sign, line, and
 * clef-octave-change elements. Sign values include G, F, C,
 * percussion, TAB, jianpu, and none. Line numbers are
 * counted from the bottom of the staff. Standard values are
 * 2 for the G sign (treble clef), 4 for the F sign (bass clef),
 * 3 for the C sign (alto clef) and 5 for TAB (on a 6-line
 * staff). The clef-octave-change element is used for
 * transposing clefs (e.g., a treble clef for tenors would
 * have a clef-octave-change value of -1). The optional
 * number attribute refers to staff numbers within the part,
 * from top to bottom on the system. A value of 1 is
 * assumed if not present.
 * 
 * The jianpu sign indicates that the music that follows
 * should be in jianpu numbered notation, just as the TAB
 * sign indicates that the music that follows should be in
 * tablature notation. Unlike TAB, a jianpu sign does not
 * correspond to a visual clef notation.
 * 
 * Sometimes clefs are added to the staff in non-standard
 * line positions, either to indicate cue passages, or when
 * there are multiple clefs present simultaneously on one
 * staff. In this situation, the additional attribute is set to
 * "yes" and the line value is ignored. The size attribute
 * is used for clefs where the additional attribute is "yes".
 * It is typically used to indicate cue clefs.
 * 
 * Sometimes clefs at the start of a measure need to appear
 * after the barline rather than before, as for cues or for
 * use after a repeated section. The after-barline attribute
 * is set to "yes" in this situation. The attribute is ignored
 * for mid-measure clefs.
 * 
 * Clefs appear at the start of each system unless the
 * print-object attribute has been set to "no" or the
 * additional attribute has been set to "yes".
 */

/**
 * The staff-details element is used to indicate different
 * types of staves. The staff-type element can be ossia,
 * cue, editorial, regular, or alternate. An alternate staff
 * indicates one that shares the same musical data as the
 * prior staff, but displayed differently (e.g., treble and
 * bass clef, standard notation and tab). The staff-lines
 * element specifies the number of lines for a non 5-line
 * staff. The staff-tuning and capo elements are used to
 * specify tuning when using tablature notation. The optional
 * number attribute specifies the staff number from top to
 * bottom on the system, as with clef. The optional show-frets
 * attribute indicates whether to show tablature frets as
 * numbers (0, 1, 2) or letters (a, b, c). The default choice
 * is numbers. The print-object attribute is used to indicate
 * when a staff is not printed in a part, usually in large
 * scores where empty parts are omitted. It is yes by default.
 * If print-spacing is yes while print-object is no, the score
 * is printed in cutaway format where vertical space is left
 * for the empty part.
 */

/**
 * The capo element indicates at which fret a capo should
 * be placed on a fretted instrument. This changes the
 * open tuning of the strings specified by staff-tuning
 * by the specified number of half-steps.
 */

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */

/**
 * The slash-type and slash-dot elements are optional children
 * of the beat-repeat and slash elements. They have the same
 * values as the type and dot elements, and define what the
 * beat is for the display of repetition marks. If not present,
 * the beat is based on the current time signature.
 */

/**
 * The unpitched element indicates musical elements that are
 * notated on the staff but lack definite pitch, such as
 * unpitched percussion and speaking voice. Like notes, it
 * uses step and octave elements to indicate placement on the
 * staff, following the current clef. If percussion clef is
 * used, the display-step and display-octave elements are
 * interpreted as if in treble clef, with a G in octave 4 on
 * line 2. If not present, the note is placed on the middle
 * line of the staff, generally used for a one-line staff.
 */

/**
 * The unpitched element indicates musical elements that are
 * notated on the staff but lack definite pitch, such as
 * unpitched percussion and speaking voice. Like notes, it
 * uses step and octave elements to indicate placement on the
 * staff, following the current clef. If percussion clef is
 * used, the display-step and display-octave elements are
 * interpreted as if in treble clef, with a G in octave 4 on
 * line 2. If not present, the note is placed on the middle
 * line of the staff, generally used for a one-line staff.
 */

/**
 * The bend element is used in guitar and tablature. The
 * bend-alter element indicates the number of steps in the
 * bend, similar to the alter element. As with the alter
 * element, numbers like 0.5 can be used to indicate
 * microtones. Negative numbers indicate pre-bends or
 * releases; the pre-bend and release elements are used
 * to distinguish what is intended. A with-bar element
 * indicates that the bend is to be done at the bridge
 * with a whammy or vibrato bar. The content of the
 * element indicates how this should be notated.
 */

/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */

/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */

/**
 * The arrow element represents an arrow used for a musical
 * technical indication. Straight arrows are represented with
 * an arrow-direction element and an optional arrow-style
 * element. Circular arrows are represented with a
 * circular-arrow element. Descriptive values use Unicode
 * arrow terminology.
 * 
 * Values for the arrow-direction element are left, up, right,
 * down, northwest, northeast, southeast, southwest, left right,
 * up down, northwest southeast, northeast southwest, and other.
 * 
 * Values for the arrow-style element are single, double,
 * filled, hollow, paired, combined, and other. Filled and
 * hollow arrows indicate polygonal single arrows. Paired
 * arrows are duplicate single arrows in the same direction.
 * Combined arrows apply to double direction arrows like
 * left right, indicating that an arrow in one direction
 * should be combined with an arrow in the other direction.
 * 
 * Values for the circular-arrow element are clockwise and
 * anticlockwise.
 */

/**
 * The arrow element represents an arrow used for a musical
 * technical indication. Straight arrows are represented with
 * an arrow-direction element and an optional arrow-style
 * element. Circular arrows are represented with a
 * circular-arrow element. Descriptive values use Unicode
 * arrow terminology.
 * 
 * Values for the arrow-direction element are left, up, right,
 * down, northwest, northeast, southeast, southwest, left right,
 * up down, northwest southeast, northeast southwest, and other.
 * 
 * Values for the arrow-style element are single, double,
 * filled, hollow, paired, combined, and other. Filled and
 * hollow arrows indicate polygonal single arrows. Paired
 * arrows are duplicate single arrows in the same direction.
 * Combined arrows apply to double direction arrows like
 * left right, indicating that an arrow in one direction
 * should be combined with an arrow in the other direction.
 * 
 * Values for the circular-arrow element are clockwise and
 * anticlockwise.
 */

/**
 * The arrow element represents an arrow used for a musical
 * technical indication. Straight arrows are represented with
 * an arrow-direction element and an optional arrow-style
 * element. Circular arrows are represented with a
 * circular-arrow element. Descriptive values use Unicode
 * arrow terminology.
 * 
 * Values for the arrow-direction element are left, up, right,
 * down, northwest, northeast, southeast, southwest, left right,
 * up down, northwest southeast, northeast southwest, and other.
 * 
 * Values for the arrow-style element are single, double,
 * filled, hollow, paired, combined, and other. Filled and
 * hollow arrows indicate polygonal single arrows. Paired
 * arrows are duplicate single arrows in the same direction.
 * Combined arrows apply to double direction arrows like
 * left right, indicating that an arrow in one direction
 * should be combined with an arrow in the other direction.
 * 
 * Values for the circular-arrow element are clockwise and
 * anticlockwise.
 */







/**
 * The glass element represents pictograms for glass
 * percussion instruments. The one valid value is
 * wind chimes.
 */

/**
 * The metal element represents pictograms for metal
 * percussion instruments. Valid values are almglocken, bell,
 * bell plate, brake drum, Chinese cymbal, cowbell,
 * crash cymbals, crotale, cymbal tongs, domed gong,
 * finger cymbals, flexatone, gong, hi-hat, high-hat cymbals,
 * handbell, sistrum, sizzle cymbal, sleigh bells,
 * suspended cymbal, tam tam, triangle, and Vietnamese hat.
 * The hi-hat value refers to a pictogram like Stone's
 * high-hat cymbals, but without the long vertical line
 * at the bottom.
 */

/**
 * The wood element represents pictograms for wood
 * percussion instruments. Valid values are board clapper,
 * cabasa, castanets, claves, guiro, log drum, maraca,
 * maracas, ratchet, sandpaper blocks, slit drum,
 * temple block, vibraslap, and wood block. The maraca
 * and maracas values distinguish the one- and two-maraca
 * versions of the pictogram. The castanets and vibraslap
 * values are in addition to Stone's list.
 */

/**
 * The pitched element represents pictograms for pitched
 * percussion instruments. Valid values are chimes,
 * glockenspiel, mallet, marimba, tubular chimes, vibraphone,
 * and xylophone. The chimes and tubular chimes values
 * distinguish the single-line and double-line versions of the
 * pictogram. The mallet value is in addition to Stone's list.
 */

/**
 * The membrane element represents pictograms for membrane
 * percussion instruments. Valid values are bass drum,
 * bass drum on side, bongos, conga drum, goblet drum,
 * military drum, snare drum, snare drum snares off,
 * tambourine, tenor drum, timbales, and tomtom. The
 * goblet drum value is in addition to Stone's list.
 */

/**
 * The effect element represents pictograms for sound effect
 * percussion instruments. Valid values are anvil, auto horn,
 * bird whistle, cannon, duck call, gun shot, klaxon horn,
 * lions roar, police whistle, siren, slide whistle,
 * thunder sheet, wind machine, and wind whistle. The cannon
 * value is in addition to Stone's list.
 */



/**
 * The stick-location element represents pictograms for the
 * location of sticks, beaters, or mallets on cymbals, gongs,
 * drums, and other instruments. Valid values are center,
 * rim, cymbal bell, and cymbal edge.
 */

/**
 * The other-percussion element represents percussion
 * pictograms not defined elsewhere.
 */



/**
 * Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */

/**
 * Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */

/**
 *     Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */

/**
 *     Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */

/**
 * The credit-type element, new in Version 3.0, indicates the
 * purpose behind a credit. Multiple types of data may be
 * combined in a single credit, so multiple elements may be
 * used. Standard values include page number, title, subtitle,
 * composer, arranger, lyricist, and rights.
 */

/**
 *     The group element allows the use of different versions of
 * the part for different purposes. Typical values include
 * score, parts, sound, and data. Ordering information that is
 * directly encoded in MuseData can be derived from the
 * ordering within a MusicXML score or opus.
 */







/**
 * Calendar dates are represented yyyy-mm-dd format, following
 * ISO 8601.
 */
mixin template ICalendarDate() {
    float month;
    float day;
    float year;
}

/**
 * The tenths entity is a number representing tenths of
 * interline space (positive or negative) for use in
 * attributes. The layout-tenths entity is the same for
 * use in elements. Both integer and decimal values are
 * allowed, such as 5 for a half space and 2.5 for a
 * quarter space. Interline space is measured from the
 * middle of a staff line.
 */
alias Tenths = float;

/**
 * The tenths entity is a number representing tenths of
 * interline space (positive or negative) for use in
 * attributes. The layout-tenths entity is the same for
 * use in elements. Both integer and decimal values are
 * allowed, such as 5 for a half space and 2.5 for a
 * quarter space. Interline space is measured from the
 * middle of a staff line.
 */
alias LayoutTenths = float;

/**
 * The start-stop and start-stop-continue entities are used
 * for musical elements that can either start or stop, such
 * as slurs, tuplets, and wedges. The start-stop-continue
 * entity is used when there is a need to refer to an
 * intermediate point in the symbol, as for complex slurs
 * or for specifying formatting of symbols across system
 * breaks. The start-stop-single entity is used when the same
 * element is used for multi-note and single-note notations,
 * as for tremolos.
 * The values of start, stop, and continue refer to how an
 * element appears in musical score order, not in MusicXML
 * document order. An element with a stop attribute may
 * precede the corresponding element with a start attribute
 * within a MusicXML document. This is particularly common
 * in multi-staff music. For example, the stopping point for
 * a slur may appear in staff 1 before the starting point for
 * the slur appears in staff 2 later in the document.
 */
export enum StartStop {
    Start = 0,
    Stop = 1
}

StartStop getStartStop(T)(T p) {
    string s = getString(p, true);
    if (s == "start") {
        return StartStop.Start;
    }
    if (s == "stop") {
        return StartStop.Stop;
    }
    assert(false, "Not reached");
}
/**
 * The start-stop and start-stop-continue entities are used
 * for musical elements that can either start or stop, such
 * as slurs, tuplets, and wedges. The start-stop-continue
 * entity is used when there is a need to refer to an
 * intermediate point in the symbol, as for complex slurs
 * or for specifying formatting of symbols across system
 * breaks. The start-stop-single entity is used when the same
 * element is used for multi-note and single-note notations,
 * as for tremolos.
 * The values of start, stop, and continue refer to how an
 * element appears in musical score order, not in MusicXML
 * document order. An element with a stop attribute may
 * precede the corresponding element with a start attribute
 * within a MusicXML document. This is particularly common
 * in multi-staff music. For example, the stopping point for
 * a slur may appear in staff 1 before the starting point for
 * the slur appears in staff 2 later in the document.
 */
export enum StartStopContinue {
    Start = 0,
    Stop = 1,
    Continue = 2
}

StartStopContinue getStartStopContinue(T)(T p) {
    string s = getString(p, true);
    if (s == "start") {
        return StartStopContinue.Start;
    }
    if (s == "stop") {
        return StartStopContinue.Stop;
    }
    if (s == "continue") {
        return StartStopContinue.Continue;
    }
    assert(false, "Not reached");
}
/**
 * The start-stop and start-stop-continue entities are used
 * for musical elements that can either start or stop, such
 * as slurs, tuplets, and wedges. The start-stop-continue
 * entity is used when there is a need to refer to an
 * intermediate point in the symbol, as for complex slurs
 * or for specifying formatting of symbols across system
 * breaks. The start-stop-single entity is used when the same
 * element is used for multi-note and single-note notations,
 * as for tremolos.
 * The values of start, stop, and continue refer to how an
 * element appears in musical score order, not in MusicXML
 * document order. An element with a stop attribute may
 * precede the corresponding element with a start attribute
 * within a MusicXML document. This is particularly common
 * in multi-staff music. For example, the stopping point for
 * a slur may appear in staff 1 before the starting point for
 * the slur appears in staff 2 later in the document.
 */
export enum StartStopSingle {
    Single = 3,
    Start = 0,
    Stop = 1
}

StartStopSingle getStartStopSingle(T)(T p) {
    string s = getString(p, true);
    if (s == "single") {
        return StartStopSingle.Single;
    }
    if (s == "start") {
        return StartStopSingle.Start;
    }
    if (s == "stop") {
        return StartStopSingle.Stop;
    }
    assert(false, "Not reached");
}
/**
 * The yes-no entity is used for boolean-like attributes.
 */

/**
 * The yes-no-number entity is used for attributes that can
 * be either boolean or numeric values. Values can be "yes",
 * "no", or numbers.
 */
mixin template IYesNoNumber() {
    bool yesNo;
    bool isYesNo;
    float num;
}

/**
 * The symbol-size entity is used to indicate full vs.
 * cue-sized vs. oversized symbols. The large value
 * for oversized symbols was added in version 1.1.
 */
export enum SymbolSize {
    Unspecified = 0,
    Full = 1,
    Cue = 2,
    Large = 3
}

SymbolSize getSymbolSize(T)(T p) {
    string s = getString(p, true);
    if (s == "unspecified") {
        return SymbolSize.Unspecified;
    }
    if (s == "full") {
        return SymbolSize.Full;
    }
    if (s == "cue") {
        return SymbolSize.Cue;
    }
    if (s == "large") {
        return SymbolSize.Large;
    }
    assert(false, "Not reached");
}
/**
 * The above-below type is used to indicate whether one
 * element appears above or below another element.
 */
export enum AboveBelow {
    Above = 1,
    Below = 2,
    Unspecified = 0
}

AboveBelow getAboveBelow(T)(T p) {
    string s = getString(p, true);
    if (s == "above") {
        return AboveBelow.Above;
    }
    if (s == "below") {
        return AboveBelow.Below;
    }
    if (s == "unspecified") {
        return AboveBelow.Unspecified;
    }
    assert(false, "Not reached");
}
export enum OverUnder {
    Over = 1,
    Under = 2,
    Unspecified = 0
}

OverUnder getOverUnder(T)(T p) {
    string s = getString(p, true);
    if (s == "over") {
        return OverUnder.Over;
    }
    if (s == "under") {
        return OverUnder.Under;
    }
    if (s == "unspecified") {
        return OverUnder.Unspecified;
    }
    assert(false, "Not reached");
}
/**
 * The up-down entity is used for arrow direction,
 * indicating which way the tip is pointing.
 */
export enum UpDown {
    Down = 1,
    Up = 0
}

UpDown getUpDown(T)(T p) {
    string s = getString(p, true);
    if (s == "down") {
        return UpDown.Down;
    }
    if (s == "up") {
        return UpDown.Up;
    }
    assert(false, "Not reached");
}
/**
 * The top-bottom entity is used to indicate the top or
 * bottom part of a vertical shape like non-arpeggiate.
 */
export enum TopBottom {
    Top = 0,
    Bottom = 1
}

TopBottom getTopBottom(T)(T p) {
    string s = getString(p, true);
    if (s == "top") {
        return TopBottom.Top;
    }
    if (s == "bottom") {
        return TopBottom.Bottom;
    }
    assert(false, "Not reached");
}
/**
 * The left-right entity is used to indicate whether one
 * element appears to the left or the right of another
 * element.
 */
export enum LeftRight {
    Right = 1,
    Left = 0
}

LeftRight getLeftRight(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return LeftRight.Right;
    }
    if (s == "left") {
        return LeftRight.Left;
    }
    assert(false, "Not reached");
}
/**
 * The number-of-lines entity is used to specify the
 * number of lines in text decoration attributes.
 */
export float NumberOfLines(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 0 && m <= 3);
    return m;
}

export float Rotation(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= -180 && m <= 180);
    return m;
}

/**
 * The enclosure-shape entity describes the shape and
 * presence / absence of an enclosure around text. A bracket
 * enclosure is similar to a rectangle with the bottom line
 * missing, as is common in jazz notation.
 */
export enum EnclosureShape {
    Circle = 3,
    Bracket = 4,
    Triangle = 5,
    Diamond = 6,
    None = 7,
    Square = 1,
    Oval = 2,
    Rectangle = 0
}

EnclosureShape getEnclosureShape(T)(T p) {
    string s = getString(p, true);
    if (s == "circle") {
        return EnclosureShape.Circle;
    }
    if (s == "bracket") {
        return EnclosureShape.Bracket;
    }
    if (s == "triangle") {
        return EnclosureShape.Triangle;
    }
    if (s == "diamond") {
        return EnclosureShape.Diamond;
    }
    if (s == "none") {
        return EnclosureShape.None;
    }
    if (s == "square") {
        return EnclosureShape.Square;
    }
    if (s == "oval") {
        return EnclosureShape.Oval;
    }
    if (s == "rectangle") {
        return EnclosureShape.Rectangle;
    }
    assert(false, "Not reached");
}
export enum NormalItalic {
    Italic = 1,
    Normal = 0
}

NormalItalic getNormalItalic(T)(T p) {
    string s = getString(p, true);
    if (s == "italic") {
        return NormalItalic.Italic;
    }
    if (s == "normal") {
        return NormalItalic.Normal;
    }
    assert(false, "Not reached");
}
export enum NormalBold {
    Bold = 2,
    Normal = 0
}

NormalBold getNormalBold(T)(T p) {
    string s = getString(p, true);
    if (s == "bold") {
        return NormalBold.Bold;
    }
    if (s == "normal") {
        return NormalBold.Normal;
    }
    assert(false, "Not reached");
}
/**
 * Slurs, tuplets, and many other features can be
 * concurrent and overlapping within a single musical
 * part. The number-level attribute distinguishes up to
 * six concurrent objects of the same type. A reading
 * program should be prepared to handle cases where
 * the number-levels stop in an arbitrary order.
 * Different numbers are needed when the features
 * overlap in MusicXML document order. When a number-level
 * value is implied, the value is 1 by default.
 */
export float NumberLevel(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 6);
    return m;
}

/**
 * The MusicXML format supports eight levels of beaming, up
 * to 1024th notes. Unlike the number-level attribute, the
 * beam-level attribute identifies concurrent beams in a beam
 * group. It does not distinguish overlapping beams such as
 * grace notes within regular notes, or beams used in different
 * voices.
 */
export float BeamLevel(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 8);
    return m;
}

/**
 * The position attributes are based on MuseData print
 * suggestions. For most elements, any program will compute
 * a default x and y position. The position attributes let
 * this be changed two ways.
 * The default-x and default-y attributes change the
 * computation of the default position. For most elements,
 * the origin is changed relative to the left-hand side of
 * the note or the musical position within the bar (x) and
 * the top line of the staff (y).
 * 
 *  
 * For the following elements, the default-x value changes
 * the origin relative to the start of the current measure:
 * 
 *     - note
 *     - figured-bass
 *     - harmony
 *     - link
 *     - directive
 *     - measure-numbering
 *     - all descendants of the part-list element
 *     - all children of the direction-type element
 * 
 * This origin is from the start of the entire measure,
 * at either the left barline or the start of the system.
 * 
 * When the default-x attribute is used within a child element
 * of the part-name-display, part-abbreviation-display,
 * group-name-display, or group-abbreviation-display elements,
 * it changes the origin relative to the start of the first
 * measure on the system. These values are used when the current
 * measure or a succeeding measure starts a new system. The same
 * change of origin is used for the group-symbol element.
 * 
 * For the note, figured-bass, and harmony elements, the
 * default-x value is considered to have adjusted the musical
 * position within the bar for its descendant elements.
 * 
 * Since the credit-words and credit-image elements are not
 * related to a measure, in these cases the default-x and
 * default-y attributes adjust the origin relative to the
 * bottom left-hand corner of the specified page.
 * 
 * The relative-x and relative-y attributes change the position
 * relative to the default position, either as computed by the
 * individual program, or as overridden by the default-x and
 * default-y attributes.
 * 
 * Positive x is right, negative x is left; positive y is up,
 * negative y is down. All units are in tenths of interline
 * space. For stems, positive relative-y lengthens a stem
 * while negative relative-y shortens it.
 * 
 * The default-x and default-y position attributes provide
 * higher-resolution positioning data than related features
 * such as the placement attribute and the offset element.
 * Applications reading a MusicXML file that can understand
 * both features should generally rely on the default-x and
 * default-y attributes for their greater accuracy. For the
 * relative-x and relative-y attributes, the offset element,
 * placement attribute, and directive attribute provide
 * context for the relative position information, so the two
 * features should be interpreted together.
 * 
 * As elsewhere in the MusicXML format, tenths are the global
 * tenths defined by the scaling element, not the local tenths
 * of a staff resized by the staff-size element.
 */
export class Position {
    mixin IPosition;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
        }
    }
}

/**
 * The position attributes are based on MuseData print
 * suggestions. For most elements, any program will compute
 * a default x and y position. The position attributes let
 * this be changed two ways.
 * The default-x and default-y attributes change the
 * computation of the default position. For most elements,
 * the origin is changed relative to the left-hand side of
 * the note or the musical position within the bar (x) and
 * the top line of the staff (y).
 * 
 *  
 * For the following elements, the default-x value changes
 * the origin relative to the start of the current measure:
 * 
 *     - note
 *     - figured-bass
 *     - harmony
 *     - link
 *     - directive
 *     - measure-numbering
 *     - all descendants of the part-list element
 *     - all children of the direction-type element
 * 
 * This origin is from the start of the entire measure,
 * at either the left barline or the start of the system.
 * 
 * When the default-x attribute is used within a child element
 * of the part-name-display, part-abbreviation-display,
 * group-name-display, or group-abbreviation-display elements,
 * it changes the origin relative to the start of the first
 * measure on the system. These values are used when the current
 * measure or a succeeding measure starts a new system. The same
 * change of origin is used for the group-symbol element.
 * 
 * For the note, figured-bass, and harmony elements, the
 * default-x value is considered to have adjusted the musical
 * position within the bar for its descendant elements.
 * 
 * Since the credit-words and credit-image elements are not
 * related to a measure, in these cases the default-x and
 * default-y attributes adjust the origin relative to the
 * bottom left-hand corner of the specified page.
 * 
 * The relative-x and relative-y attributes change the position
 * relative to the default position, either as computed by the
 * individual program, or as overridden by the default-x and
 * default-y attributes.
 * 
 * Positive x is right, negative x is left; positive y is up,
 * negative y is down. All units are in tenths of interline
 * space. For stems, positive relative-y lengthens a stem
 * while negative relative-y shortens it.
 * 
 * The default-x and default-y position attributes provide
 * higher-resolution positioning data than related features
 * such as the placement attribute and the offset element.
 * Applications reading a MusicXML file that can understand
 * both features should generally rely on the default-x and
 * default-y attributes for their greater accuracy. For the
 * relative-x and relative-y attributes, the offset element,
 * placement attribute, and directive attribute provide
 * context for the relative position information, so the two
 * features should be interpreted together.
 * 
 * As elsewhere in the MusicXML format, tenths are the global
 * tenths defined by the scaling element, not the local tenths
 * of a staff resized by the staff-size element.
 */
mixin template IPosition() {
    float defaultX;
    float relativeY;
    float defaultY;
    float relativeX;
}

/**
 * The placement attribute indicates whether something is
 * above or below another element, such as a note or a
 * notation.
 */
export class Placement {
    mixin IPlacement;
    this(xmlNodePtr node) {
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The placement attribute indicates whether something is
 * above or below another element, such as a note or a
 * notation.
 */
mixin template IPlacement() {
    AboveBelow placement;
}

/**
 * The orientation attribute indicates whether slurs and
 * ties are overhand (tips down) or underhand (tips up).
 * This is distinct from the placement entity used by any
 * notation type.
 */
export class Orientation {
    mixin IOrientation;
    this(xmlNodePtr node) {
        bool foundOrientation = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "orientation") {
                auto data = getOverUnder(ch);
                this.orientation = data;
                foundOrientation = true;
            }
        }
        if (!foundOrientation) {
            orientation = OverUnder.Unspecified;
        }
    }
}

/**
 * The orientation attribute indicates whether slurs and
 * ties are overhand (tips down) or underhand (tips up).
 * This is distinct from the placement entity used by any
 * notation type.
 */
mixin template IOrientation() {
    OverUnder orientation;
}

/**
 * The directive entity changes the default-x position
 * of a direction. It indicates that the left-hand side of the
 * direction is aligned with the left-hand side of the time
 * signature. If no time signature is present, it is aligned
 * with the left-hand side of the first music notational
 * element in the measure. If a default-x, justify, or halign
 * attribute is present, it overrides the directive entity.
 */
export class DirectiveEntity {
    mixin IDirectiveEntity;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "directive-entity") {
                auto data = getYesNo(ch, true);
                this.directiveEntity = data;
            }
        }
    }
}

/**
 * The directive entity changes the default-x position
 * of a direction. It indicates that the left-hand side of the
 * direction is aligned with the left-hand side of the time
 * signature. If no time signature is present, it is aligned
 * with the left-hand side of the first music notational
 * element in the measure. If a default-x, justify, or halign
 * attribute is present, it overrides the directive entity.
 */
mixin template IDirectiveEntity() {
    bool directiveEntity;
}

/**
 * The bezier entity is used to indicate the curvature of
 * slurs and ties, representing the control points for a
 * cubic bezier curve. For ties, the bezier entity is
 * used with the tied element.
 * Normal slurs, S-shaped slurs, and ties need only two
 * bezier points: one associated with the start of the slur
 * or tie, the other with the stop. Complex slurs and slurs
 * divided over system breaks can specify additional
 * bezier data at slur elements with a continue type.
 * 
 * The bezier-offset, bezier-x, and bezier-y attributes
 * describe the outgoing bezier point for slurs and ties
 * with a start type, and the incoming bezier point for
 * slurs and ties with types of stop or continue. The
 * attributes bezier-offset2, bezier-x2, and bezier-y2
 * are only valid with slurs of type continue, and
 * describe the outgoing bezier point.
 * 
 * The bezier-offset and bezier-offset2 attributes are
 * measured in terms of musical divisions, like the offset
 * element. These are the recommended attributes for
 * specifying horizontal position. The other attributes
 * are specified in tenths, relative to any position
 * settings associated with the slur or tied element.
 */
export class Bezier {
    mixin IBezier;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "bezier-x2") {
                auto data = getNumber(ch, true);
                this.bezierX2 = data;
            }
            if (ch.name.toString == "bezier-offset") {
                auto data = getNumber(ch, true);
                this.bezierOffset = data;
            }
            if (ch.name.toString == "bezier-offset2") {
                auto data = getNumber(ch, true);
                this.bezierOffset2 = data;
            }
            if (ch.name.toString == "bezier-x") {
                auto data = getNumber(ch, true);
                this.bezierX = data;
            }
            if (ch.name.toString == "bezier-y") {
                auto data = getNumber(ch, true);
                this.bezierY = data;
            }
            if (ch.name.toString == "bezier-y2") {
                auto data = getNumber(ch, true);
                this.bezierY2 = data;
            }
        }
    }
}

/**
 * The bezier entity is used to indicate the curvature of
 * slurs and ties, representing the control points for a
 * cubic bezier curve. For ties, the bezier entity is
 * used with the tied element.
 * Normal slurs, S-shaped slurs, and ties need only two
 * bezier points: one associated with the start of the slur
 * or tie, the other with the stop. Complex slurs and slurs
 * divided over system breaks can specify additional
 * bezier data at slur elements with a continue type.
 * 
 * The bezier-offset, bezier-x, and bezier-y attributes
 * describe the outgoing bezier point for slurs and ties
 * with a start type, and the incoming bezier point for
 * slurs and ties with types of stop or continue. The
 * attributes bezier-offset2, bezier-x2, and bezier-y2
 * are only valid with slurs of type continue, and
 * describe the outgoing bezier point.
 * 
 * The bezier-offset and bezier-offset2 attributes are
 * measured in terms of musical divisions, like the offset
 * element. These are the recommended attributes for
 * specifying horizontal position. The other attributes
 * are specified in tenths, relative to any position
 * settings associated with the slur or tied element.
 */
mixin template IBezier() {
    float bezierX2;
    float bezierOffset;
    float bezierOffset2;
    float bezierX;
    float bezierY;
    float bezierY2;
}

/**
 * The font entity gathers together attributes for
 * determining the font within a directive or direction.
 * They are based on the text styles for Cascading
 * Style Sheets. The font-family is a comma-separated list
 * of font names. These can be specific font styles such
 * as Maestro or Opus, or one of several generic font styles:
 * music, engraved, handwritten, text, serif, sans-serif,
 * handwritten, cursive, fantasy, and monospace. The music,
 * engraved, and handwritten values refer to music fonts;
 * the rest refer to text fonts. The fantasy style refers to
 * decorative text such as found in older German-style
 * printing. The font-style can be normal or italic. The
 * font-size can be one of the CSS sizes (xx-small, x-small,
 * small, medium, large, x-large, xx-large) or a numeric
 * point size. The font-weight can be normal or bold. The
 * default is application-dependent, but is a text font vs.
 * a music font.
 */
export class Font {
    mixin IFont;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
    }
}

/**
 * The font entity gathers together attributes for
 * determining the font within a directive or direction.
 * They are based on the text styles for Cascading
 * Style Sheets. The font-family is a comma-separated list
 * of font names. These can be specific font styles such
 * as Maestro or Opus, or one of several generic font styles:
 * music, engraved, handwritten, text, serif, sans-serif,
 * handwritten, cursive, fantasy, and monospace. The music,
 * engraved, and handwritten values refer to music fonts;
 * the rest refer to text fonts. The fantasy style refers to
 * decorative text such as found in older German-style
 * printing. The font-style can be normal or italic. The
 * font-size can be one of the CSS sizes (xx-small, x-small,
 * small, medium, large, x-large, xx-large) or a numeric
 * point size. The font-weight can be normal or bold. The
 * default is application-dependent, but is a text font vs.
 * a music font.
 */
mixin template IFont() {
    string fontFamily;
    NormalBold fontWeight;
    NormalItalic fontStyle;
    string fontSize;
}

export enum LeftCenterRight {
    Right = 1,
    Center = 2,
    Left = 0
}

LeftCenterRight getLeftCenterRight(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return LeftCenterRight.Right;
    }
    if (s == "center") {
        return LeftCenterRight.Center;
    }
    if (s == "left") {
        return LeftCenterRight.Left;
    }
    assert(false, "Not reached");
}
export enum TopMiddleBottomBaseline {
    Top = 0,
    Middle = 1,
    Baseline = 3,
    Bottom = 2
}

TopMiddleBottomBaseline getTopMiddleBottomBaseline(T)(T p) {
    string s = getString(p, true);
    if (s == "top") {
        return TopMiddleBottomBaseline.Top;
    }
    if (s == "middle") {
        return TopMiddleBottomBaseline.Middle;
    }
    if (s == "baseline") {
        return TopMiddleBottomBaseline.Baseline;
    }
    if (s == "bottom") {
        return TopMiddleBottomBaseline.Bottom;
    }
    assert(false, "Not reached");
}
export enum DirectionMode {
    Lro = 2,
    Rlo = 3,
    Ltr = 0,
    Rtl = 1
}

DirectionMode getDirectionMode(T)(T p) {
    string s = getString(p, true);
    if (s == "lro") {
        return DirectionMode.Lro;
    }
    if (s == "rlo") {
        return DirectionMode.Rlo;
    }
    if (s == "ltr") {
        return DirectionMode.Ltr;
    }
    if (s == "rtl") {
        return DirectionMode.Rtl;
    }
    assert(false, "Not reached");
}
export enum StraightCurved {
    Curved = 1,
    Straight = 0
}

StraightCurved getStraightCurved(T)(T p) {
    string s = getString(p, true);
    if (s == "curved") {
        return StraightCurved.Curved;
    }
    if (s == "straight") {
        return StraightCurved.Straight;
    }
    assert(false, "Not reached");
}
export enum SolidDashedDottedWavy {
    Dashed = 1,
    Wavy = 3,
    Dotted = 2,
    Solid = 0
}

SolidDashedDottedWavy getSolidDashedDottedWavy(T)(T p) {
    string s = getString(p, true);
    if (s == "dashed") {
        return SolidDashedDottedWavy.Dashed;
    }
    if (s == "wavy") {
        return SolidDashedDottedWavy.Wavy;
    }
    if (s == "dotted") {
        return SolidDashedDottedWavy.Dotted;
    }
    if (s == "solid") {
        return SolidDashedDottedWavy.Solid;
    }
    assert(false, "Not reached");
}
export enum NormalAngledSquare {
    Angled = 1,
    Square = 2,
    Normal = 0
}

NormalAngledSquare getNormalAngledSquare(T)(T p) {
    string s = getString(p, true);
    if (s == "angled") {
        return NormalAngledSquare.Angled;
    }
    if (s == "square") {
        return NormalAngledSquare.Square;
    }
    if (s == "normal") {
        return NormalAngledSquare.Normal;
    }
    assert(false, "Not reached");
}
export enum UprightInverted {
    Upright = 0,
    Inverted = 1
}

UprightInverted getUprightInverted(T)(T p) {
    string s = getString(p, true);
    if (s == "upright") {
        return UprightInverted.Upright;
    }
    if (s == "inverted") {
        return UprightInverted.Inverted;
    }
    assert(false, "Not reached");
}
export enum UpperMainBelow {
    Main = 1,
    Below = 2,
    Upper = 0
}

UpperMainBelow getUpperMainBelow(T)(T p) {
    string s = getString(p, true);
    if (s == "main") {
        return UpperMainBelow.Main;
    }
    if (s == "below") {
        return UpperMainBelow.Below;
    }
    if (s == "upper") {
        return UpperMainBelow.Upper;
    }
    assert(false, "Not reached");
}
export enum WholeHalfUnison {
    Unison = 2,
    Whole = 0,
    Half = 1
}

WholeHalfUnison getWholeHalfUnison(T)(T p) {
    string s = getString(p, true);
    if (s == "unison") {
        return WholeHalfUnison.Unison;
    }
    if (s == "whole") {
        return WholeHalfUnison.Whole;
    }
    if (s == "half") {
        return WholeHalfUnison.Half;
    }
    assert(false, "Not reached");
}
export enum WholeHalfNone {
    None = 3,
    Whole = 0,
    Half = 1
}

WholeHalfNone getWholeHalfNone(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return WholeHalfNone.None;
    }
    if (s == "whole") {
        return WholeHalfNone.Whole;
    }
    if (s == "half") {
        return WholeHalfNone.Half;
    }
    assert(false, "Not reached");
}
/**
 * The color entity indicates the color of an element.
 * Color may be represented as hexadecimal RGB triples,
 * as in HTML, or as hexadecimal ARGB tuples, with the
 * A indicating alpha of transparency. An alpha value
 * of 00 is totally transparent; FF is totally opaque.
 * If RGB is used, the A value is assumed to be FF.
 * For instance, the RGB value "#800080" represents
 * purple. An ARGB value of "#40800080" would be a
 * transparent purple.
 *  
 *  
 * As in SVG 1.1, colors are defined in terms of the 
 * sRGB color space (IEC 61966).
 */
export class Color {
    mixin IColor;
    this(xmlNodePtr node) {
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The color entity indicates the color of an element.
 * Color may be represented as hexadecimal RGB triples,
 * as in HTML, or as hexadecimal ARGB tuples, with the
 * A indicating alpha of transparency. An alpha value
 * of 00 is totally transparent; FF is totally opaque.
 * If RGB is used, the A value is assumed to be FF.
 * For instance, the RGB value "#800080" represents
 * purple. An ARGB value of "#40800080" would be a
 * transparent purple.
 *  
 *  
 * As in SVG 1.1, colors are defined in terms of the 
 * sRGB color space (IEC 61966).
 */
mixin template IColor() {
    string color;
}

/**
 * The text-decoration entity is based on the similar
 * feature in XHTML and CSS. It allows for text to
 * be underlined, overlined, or struck-through. It
 * extends the CSS version by allow double or
 * triple lines instead of just being on or off.
 */
export class TextDecoration {
    mixin ITextDecoration;
    this(xmlNodePtr node) {
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
    }
}

/**
 * The text-decoration entity is based on the similar
 * feature in XHTML and CSS. It allows for text to
 * be underlined, overlined, or struck-through. It
 * extends the CSS version by allow double or
 * triple lines instead of just being on or off.
 */
mixin template ITextDecoration() {
    float underline;
    float overline;
    float lineThrough;
}

/**
 * The justify entity is used to indicate left, center, or
 * right justification. The default value varies for different
 * elements. For elements where the justify attribute is present
 * but the halign attribute is not, the justify attribute
 * indicates horizontal alignment as well as justification.
 */
export class Justify {
    mixin IJustify;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 * The justify entity is used to indicate left, center, or
 * right justification. The default value varies for different
 * elements. For elements where the justify attribute is present
 * but the halign attribute is not, the justify attribute
 * indicates horizontal alignment as well as justification.
 */
mixin template IJustify() {
    LeftCenterRight justify;
}

/**
 * In cases where text extends over more than one line,
 * horizontal alignment and justify values can be different.
 * The most typical case is for credits, such as:
 * Words and music by
 *   Pat Songwriter
 *  
 *  
 * Typically this type of credit is aligned to the right, 
 * so that the position information refers to the right- 
 * most part of the text. But in this example, the text 
 * is center-justified, not right-justified.  
 *  
 * The halign attribute is used in these situations. If it 
 * is not present, its value is the same as for the justify 
 * attribute.
 */
mixin template IHalign() {
    LeftCenterRight halign;
}

/**
 * The valign entity is used to indicate vertical
 * alignment to the top, middle, bottom, or baseline
 * of the text. Defaults are implementation-dependent.
 */
export class Valign {
    mixin IValign;
    this(xmlNodePtr node) {
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The valign entity is used to indicate vertical
 * alignment to the top, middle, bottom, or baseline
 * of the text. Defaults are implementation-dependent.
 */
mixin template IValign() {
    TopMiddleBottomBaseline valign;
}

/**
 * The valign-image entity is used to indicate vertical
 * alignment for images and graphics, so it removes the
 * baseline value. Defaults are implementation-dependent.
 */
export class ValignImage {
    mixin IValignImage;
    this(xmlNodePtr node) {
        bool foundValignImage = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "valign-image") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valignImage = data;
                foundValignImage = true;
            }
        }
        if (!foundValignImage) {
            valignImage = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The valign-image entity is used to indicate vertical
 * alignment for images and graphics, so it removes the
 * baseline value. Defaults are implementation-dependent.
 */
mixin template IValignImage() {
    TopMiddleBottomBaseline valignImage;
}

/**
 * The letter-spacing entity specifies text tracking.
 * Values are either "normal" or a number representing
 * the number of ems to add between each letter. The
 * number may be negative in order to subtract space.
 * The default is normal, which allows flexibility of
 * letter-spacing for purposes of text justification.
 */
export class LetterSpacing {
    mixin ILetterSpacing;
    this(xmlNodePtr node) {
        bool foundLetterSpacing = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
    }
}

/**
 * The letter-spacing entity specifies text tracking.
 * Values are either "normal" or a number representing
 * the number of ems to add between each letter. The
 * number may be negative in order to subtract space.
 * The default is normal, which allows flexibility of
 * letter-spacing for purposes of text justification.
 */
mixin template ILetterSpacing() {
    string letterSpacing;
}

/**
 * The line-height entity specified text leading. Values
 * are either "normal" or a number representing the
 * percentage of the current font height  to use for
 * leading. The default is "normal". The exact normal
 * value is implementation-dependent, but values
 * between 100 and 120 are recommended.
 */
export class LineHeight {
    mixin ILineHeight;
    this(xmlNodePtr node) {
        bool foundLineHeight = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
    }
}

/**
 * The line-height entity specified text leading. Values
 * are either "normal" or a number representing the
 * percentage of the current font height  to use for
 * leading. The default is "normal". The exact normal
 * value is implementation-dependent, but values
 * between 100 and 120 are recommended.
 */
mixin template ILineHeight() {
    string lineHeight;
}

/**
 * The text-direction entity is used to adjust and override
 * the Unicode bidirectional text algorithm, similar to the
 * W3C Internationalization Tag Set recommendation. Values
 * are ltr (left-to-right embed), rtl (right-to-left embed),
 * lro (left-to-right bidi-override), and rlo (right-to-left
 * bidi-override). The default value is ltr. This entity
 * is typically used by applications that store text in
 * left-to-right visual order rather than logical order.
 * Such applications can use the lro value to better
 * communicate with other applications that more fully
 * support bidirectional text.
 */
export class TextDirection {
    mixin ITextDirection;
    this(xmlNodePtr node) {
        bool foundDir = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
    }
}

/**
 * The text-direction entity is used to adjust and override
 * the Unicode bidirectional text algorithm, similar to the
 * W3C Internationalization Tag Set recommendation. Values
 * are ltr (left-to-right embed), rtl (right-to-left embed),
 * lro (left-to-right bidi-override), and rlo (right-to-left
 * bidi-override). The default value is ltr. This entity
 * is typically used by applications that store text in
 * left-to-right visual order rather than logical order.
 * Such applications can use the lro value to better
 * communicate with other applications that more fully
 * support bidirectional text.
 */
mixin template ITextDirection() {
    DirectionMode dir;
}

/**
 * The text-rotation entity is used to rotate text
 * around the alignment point specified by the
 * halign and valign entities. The value is a number
 * ranging from -180 to 180. Positive values are
 * clockwise rotations, while negative values are
 * counter-clockwise rotations.
 */
export class TextRotation {
    mixin ITextRotation;
    this(xmlNodePtr node) {
        bool foundRotation = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
        }
        if (!foundRotation) {
            rotation = 0;
        }
    }
}

/**
 * The text-rotation entity is used to rotate text
 * around the alignment point specified by the
 * halign and valign entities. The value is a number
 * ranging from -180 to 180. Positive values are
 * clockwise rotations, while negative values are
 * counter-clockwise rotations.
 */
mixin template ITextRotation() {
    float rotation;
}

/**
 * The enclosure entity is used to specify the
 * formatting of an enclosure around text or symbols.
 */
export class Enclosure {
    mixin IEnclosure;
    this(xmlNodePtr node) {
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * The enclosure entity is used to specify the
 * formatting of an enclosure around text or symbols.
 */
mixin template IEnclosure() {
    EnclosureShape enclosure;
}

/**
 * The print-style entity groups together the most popular
 * combination of printing attributes: position, font, and
 * color.
 */
export class PrintStyle {
    mixin IPrintStyle;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The print-style entity groups together the most popular
 * combination of printing attributes: position, font, and
 * color.
 */
mixin template IPrintStyle() {
    mixin IPosition;
    mixin IFont;
    mixin IColor;
}

/**
 * The print-style-align entity adds the halign and valign
 * attributes to the position, font, and color attributes.
 */
mixin template IPrintStyleAlign() {
    mixin IPrintStyle;
    mixin IHalign;
    mixin IValign;
}

/**
 * The line-shape entity is used to distinguish between
 * straight and curved lines. The line-type entity
 * distinguishes between solid, dashed, dotted, and
 * wavy lines.
 */
export class LineShape {
    mixin ILineShape;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
    }
}

/**
 * The line-shape entity is used to distinguish between
 * straight and curved lines. The line-type entity
 * distinguishes between solid, dashed, dotted, and
 * wavy lines.
 */
mixin template ILineShape() {
    StraightCurved lineShape;
}

/**
 * The line-shape entity is used to distinguish between
 * straight and curved lines. The line-type entity
 * distinguishes between solid, dashed, dotted, and
 * wavy lines.
 */
mixin template ILineType() {
    SolidDashedDottedWavy lineType;
}

/**
 * The dashed-formatting entity represents the length of
 * dashes and spaces in a dashed line. Both the dash-length
 * and space-length attributes are represented in tenths.
 * These attributes are ignored if the corresponding
 * line-type attribute is not dashed.
 */
export class DashedFormatting {
    mixin IDashedFormatting;
    this(xmlNodePtr node) {
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
    }
}

/**
 * The dashed-formatting entity represents the length of
 * dashes and spaces in a dashed line. Both the dash-length
 * and space-length attributes are represented in tenths.
 * These attributes are ignored if the corresponding
 * line-type attribute is not dashed.
 */
mixin template IDashedFormatting() {
    float dashLength;
    float spaceLength;
}

/**
 * The printout entity is based on MuseData print
 * suggestions. They allow a way to specify not to print
 * print an object (e.g. note or rest), its augmentation
 * dots, or its lyrics. This is especially useful for notes
 * that overlap in different voices, or for chord sheets
 * that contain lyrics and chords but no melody. For wholly
 * invisible notes, such as those providing sound-only data,
 * the attribute for print-spacing may be set to no so that
 * no space is left for this note. The print-spacing value
 * is only used if no note, dot, or lyric is being printed.
 * By default, all these attributes are set to yes. If
 * print-object is set to no, print-dot and print-lyric are
 * interpreted to also be set to no if they are not present.
 */
export class PrintObject {
    mixin IPrintObject;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * The printout entity is based on MuseData print
 * suggestions. They allow a way to specify not to print
 * print an object (e.g. note or rest), its augmentation
 * dots, or its lyrics. This is especially useful for notes
 * that overlap in different voices, or for chord sheets
 * that contain lyrics and chords but no melody. For wholly
 * invisible notes, such as those providing sound-only data,
 * the attribute for print-spacing may be set to no so that
 * no space is left for this note. The print-spacing value
 * is only used if no note, dot, or lyric is being printed.
 * By default, all these attributes are set to yes. If
 * print-object is set to no, print-dot and print-lyric are
 * interpreted to also be set to no if they are not present.
 */
mixin template IPrintObject() {
    bool printObject;
}

/**
 * The printout entity is based on MuseData print
 * suggestions. They allow a way to specify not to print
 * print an object (e.g. note or rest), its augmentation
 * dots, or its lyrics. This is especially useful for notes
 * that overlap in different voices, or for chord sheets
 * that contain lyrics and chords but no melody. For wholly
 * invisible notes, such as those providing sound-only data,
 * the attribute for print-spacing may be set to no so that
 * no space is left for this note. The print-spacing value
 * is only used if no note, dot, or lyric is being printed.
 * By default, all these attributes are set to yes. If
 * print-object is set to no, print-dot and print-lyric are
 * interpreted to also be set to no if they are not present.
 */
export class PrintSpacing {
    mixin IPrintSpacing;
    this(xmlNodePtr node) {
        bool foundPrintSpacing = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-spacing") {
                auto data = getYesNo(ch, true);
                this.printSpacing = data;
                foundPrintSpacing = true;
            }
        }
        if (!foundPrintSpacing) {
            printSpacing = true;
        }
    }
}

/**
 * The printout entity is based on MuseData print
 * suggestions. They allow a way to specify not to print
 * print an object (e.g. note or rest), its augmentation
 * dots, or its lyrics. This is especially useful for notes
 * that overlap in different voices, or for chord sheets
 * that contain lyrics and chords but no melody. For wholly
 * invisible notes, such as those providing sound-only data,
 * the attribute for print-spacing may be set to no so that
 * no space is left for this note. The print-spacing value
 * is only used if no note, dot, or lyric is being printed.
 * By default, all these attributes are set to yes. If
 * print-object is set to no, print-dot and print-lyric are
 * interpreted to also be set to no if they are not present.
 */
mixin template IPrintSpacing() {
    bool printSpacing;
}

/**
 * The printout entity is based on MuseData print
 * suggestions. They allow a way to specify not to print
 * print an object (e.g. note or rest), its augmentation
 * dots, or its lyrics. This is especially useful for notes
 * that overlap in different voices, or for chord sheets
 * that contain lyrics and chords but no melody. For wholly
 * invisible notes, such as those providing sound-only data,
 * the attribute for print-spacing may be set to no so that
 * no space is left for this note. The print-spacing value
 * is only used if no note, dot, or lyric is being printed.
 * By default, all these attributes are set to yes. If
 * print-object is set to no, print-dot and print-lyric are
 * interpreted to also be set to no if they are not present.
 */
mixin template IPrintout() {
    mixin IPrintObject;
    mixin IPrintSpacing;
    bool printDot;
    bool printLyric;
}

/**
 * The text-formatting entity contains the common formatting
 * attributes for text elements. Default values may differ
 * across the elements that use this entity.
 */
export class TextFormatting {
    mixin ITextFormatting;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * The text-formatting entity contains the common formatting
 * attributes for text elements. Default values may differ
 * across the elements that use this entity.
 */
mixin template ITextFormatting() {
    mixin IJustify;
    mixin IPrintStyleAlign;
    mixin ITextDecoration;
    mixin ITextRotation;
    mixin ILetterSpacing;
    mixin ILineHeight;
    mixin ITextDirection;
    mixin IEnclosure;
}

/**
 * The level-display entity allows specification of three
 * common ways to indicate editorial indications: putting
 * parentheses or square brackets around a symbol, or making
 * the symbol a different size. If not specified, they are
 * left to application defaults. It is used by the level and
 * accidental elements.
 */
export class LevelDisplay {
    mixin ILevelDisplay;
    this(xmlNodePtr node) {
        bool foundBracket = false;
        bool foundSize = false;
        bool foundParentheses = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "bracket") {
                auto data = getYesNo(ch, true);
                this.bracket = data;
                foundBracket = true;
            }
            if (ch.name.toString == "size") {
                auto data = getSymbolSize(ch);
                this.size = data;
                foundSize = true;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
                foundParentheses = true;
            }
        }
        if (!foundBracket) {
            bracket = false;
        }
        if (!foundSize) {
            size = SymbolSize.Unspecified;
        }
        if (!foundParentheses) {
            parentheses = false;
        }
    }
}

/**
 * The level-display entity allows specification of three
 * common ways to indicate editorial indications: putting
 * parentheses or square brackets around a symbol, or making
 * the symbol a different size. If not specified, they are
 * left to application defaults. It is used by the level and
 * accidental elements.
 */
mixin template ILevelDisplay() {
    bool bracket;
    SymbolSize size;
    bool parentheses;
}

/**
 * The trill-sound entity includes attributes used to guide
 * the sound of trills, mordents, turns, shakes, and wavy
 * lines, based on MuseData sound suggestions. The default
 * choices are:
 * 
 * start-note = "upper"
 * 
 * trill-step = "whole"        two-note-turn = "none"
 * 
 * accelerate = "no"        beats = "4" (minimum of "2").
 * 
 * Second-beat and last-beat are percentages for landing on
 * the indicated beat, with defaults of 25 and 75 respectively.
 * 
 * For mordent and inverted-mordent elements, the defaults
 * are different:
 * 
 * The default start-note is "main", not "upper".
 * The default for beats is "3", not "4".
 * The default for second-beat is "12", not "25".
 * The default for last-beat is "24", not "75".
 */
export class TrillSound {
    mixin ITrillSound;
    this(xmlNodePtr node) {
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The trill-sound entity includes attributes used to guide
 * the sound of trills, mordents, turns, shakes, and wavy
 * lines, based on MuseData sound suggestions. The default
 * choices are:
 * 
 * start-note = "upper"
 * 
 * trill-step = "whole"        two-note-turn = "none"
 * 
 * accelerate = "no"        beats = "4" (minimum of "2").
 * 
 * Second-beat and last-beat are percentages for landing on
 * the indicated beat, with defaults of 25 and 75 respectively.
 * 
 * For mordent and inverted-mordent elements, the defaults
 * are different:
 * 
 * The default start-note is "main", not "upper".
 * The default for beats is "3", not "4".
 * The default for second-beat is "12", not "25".
 * The default for last-beat is "24", not "75".
 */
mixin template ITrillSound() {
    UpperMainBelow startNote;
    bool accelerate;
    float beats;
    float lastBeat;
    WholeHalfUnison trillStep;
    WholeHalfNone twoNoteTurn;
    float secondBeat;
}

/**
 * The bend-sound entity is used for bend and slide elements,
 * and is similar to the trill-sound. Here the beats element
 * refers to the number of discrete elements (like MIDI pitch
 * bends) used to represent a continuous bend or slide. The
 * first-beat indicates the percentage of the direction for
 * starting a bend; the last-beat the percentage for ending it.
 * The default choices are:
 * 
 * accelerate = "no"
 * 
 * beats = "4" (minimum of "2")
 * first-beat = "25"
 * 
 * last-beat = "75"
 */
export class BendSound {
    mixin IBendSound;
    this(xmlNodePtr node) {
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The bend-sound entity is used for bend and slide elements,
 * and is similar to the trill-sound. Here the beats element
 * refers to the number of discrete elements (like MIDI pitch
 * bends) used to represent a continuous bend or slide. The
 * first-beat indicates the percentage of the direction for
 * starting a bend; the last-beat the percentage for ending it.
 * The default choices are:
 * 
 * accelerate = "no"
 * 
 * beats = "4" (minimum of "2")
 * first-beat = "25"
 * 
 * last-beat = "75"
 */
mixin template IBendSound() {
    bool accelerate;
    float beats;
    float lastBeat;
    float secondBeat;
}

/**
 * The time-only entity is used to indicate that a particular
 * playback-related element only applies particular times through
 * a repeated section.
 */
export class TimeOnly {
    mixin ITimeOnly;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "time-only") {
                auto data = getString(ch, true);
                this.timeOnly = data;
            }
        }
    }
}

/**
 * The time-only entity is used to indicate that a particular
 * playback-related element only applies particular times through
 * a repeated section.
 */
mixin template ITimeOnly() {
    string timeOnly;
}

/**
 * The document-attributes entity is used to specify the
 * attributes for an entire MusicXML document. Currently
 * this is used for the version attribute.
 */
export class DocumentAttributes {
    mixin IDocumentAttributes;
    this(xmlNodePtr node) {
        bool foundVersion_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "version") {
                auto data = getString(ch, true);
                this.version_ = data;
                foundVersion_ = true;
            }
        }
        if (!foundVersion_) {
            version_ = "1.0";
        }
    }
}

/**
 * The document-attributes entity is used to specify the
 * attributes for an entire MusicXML document. Currently
 * this is used for the version attribute.
 */
mixin template IDocumentAttributes() {
    string version_;
}

/**
 * Two entities for editorial information in notes. These
 * entities, and their elements defined below, are used
 * across all the different component DTD modules.
 */
export class Editorial {
    mixin IEditorial;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Two entities for editorial information in notes. These
 * entities, and their elements defined below, are used
 * across all the different component DTD modules.
 */
mixin template IEditorial() {
    Footnote footnote;
    Level level;
}

/**
 * Two entities for editorial information in notes. These
 * entities, and their elements defined below, are used
 * across all the different component DTD modules.
 */
export class EditorialVoice {
    mixin IEditorialVoice;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "voice") {
                auto data = getNumber(ch, true);
                this.voice = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Two entities for editorial information in notes. These
 * entities, and their elements defined below, are used
 * across all the different component DTD modules.
 */
mixin template IEditorialVoice() {
    float voice;
    Footnote footnote;
    Level level;
}

/**
 * Footnote and level are used to specify editorial
 * information, while voice is used to distinguish between
 * multiple voices (what MuseData calls tracks) in individual
 * parts. These elements are used throughout the different
 * MusicXML DTD modules. If the reference attribute for the
 * level element is yes, this indicates editorial information
 * that is for display only and should not affect playback.
 * For instance, a modern edition of older music may set
 * reference="yes" on the attributes containing the music's
 * original clef, key, and time signature. It is no by default.
 */
export class Footnote {
    mixin IFootnote;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * Footnote and level are used to specify editorial
 * information, while voice is used to distinguish between
 * multiple voices (what MuseData calls tracks) in individual
 * parts. These elements are used throughout the different
 * MusicXML DTD modules. If the reference attribute for the
 * level element is yes, this indicates editorial information
 * that is for display only and should not affect playback.
 * For instance, a modern edition of older music may set
 * reference="yes" on the attributes containing the music's
 * original clef, key, and time signature. It is no by default.
 */
mixin template IFootnote() {
    mixin ITextFormatting;
    string text;
}

/**
 * Footnote and level are used to specify editorial
 * information, while voice is used to distinguish between
 * multiple voices (what MuseData calls tracks) in individual
 * parts. These elements are used throughout the different
 * MusicXML DTD modules. If the reference attribute for the
 * level element is yes, this indicates editorial information
 * that is for display only and should not affect playback.
 * For instance, a modern edition of older music may set
 * reference="yes" on the attributes containing the music's
 * original clef, key, and time signature. It is no by default.
 */
export class Level {
    mixin ILevel;
    this(xmlNodePtr node) {
        bool foundBracket = false;
        bool foundSize = false;
        bool foundParentheses = false;
        bool foundReference = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "bracket") {
                auto data = getYesNo(ch, true);
                this.bracket = data;
                foundBracket = true;
            }
            if (ch.name.toString == "size") {
                auto data = getSymbolSize(ch);
                this.size = data;
                foundSize = true;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
                foundParentheses = true;
            }
            if (ch.name.toString == "reference") {
                auto data = getYesNo(ch, true);
                this.reference = data;
                foundReference = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundBracket) {
            bracket = false;
        }
        if (!foundSize) {
            size = SymbolSize.Unspecified;
        }
        if (!foundParentheses) {
            parentheses = false;
        }
        if (!foundReference) {
            reference = false;
        }
    }
}

/**
 * Footnote and level are used to specify editorial
 * information, while voice is used to distinguish between
 * multiple voices (what MuseData calls tracks) in individual
 * parts. These elements are used throughout the different
 * MusicXML DTD modules. If the reference attribute for the
 * level element is yes, this indicates editorial information
 * that is for display only and should not affect playback.
 * For instance, a modern edition of older music may set
 * reference="yes" on the attributes containing the music's
 * original clef, key, and time signature. It is no by default.
 */
mixin template ILevel() {
    mixin ILevelDisplay;
    string text;
    bool reference;
}

/**
 * Fermata and wavy-line elements can be applied both to
 * notes and to measures, so they are defined here. Wavy
 * lines are one way to indicate trills; when used with a
 * measure element, they should always have type="continue"
 * 
 * set. The fermata text content represents the shape of the
 * fermata sign and may be normal, angled, or square.
 * An empty fermata element represents a normal fermata.
 * The fermata type is upright if not specified.
 */
export class Fermata {
    mixin IFermata;
    this(xmlNodePtr node) {
        bool foundShape = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getUprightInverted(ch);
                this.type = data;
                foundType = true;
            }
        }
        auto ch = node;
        auto data = getNormalAngledSquare(ch);
        this.shape = data;
        if (!foundShape) {
            shape = NormalAngledSquare.Normal;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundType) {
            type = UprightInverted.Upright;
        }
    }
}

/**
 * Fermata and wavy-line elements can be applied both to
 * notes and to measures, so they are defined here. Wavy
 * lines are one way to indicate trills; when used with a
 * measure element, they should always have type="continue"
 * 
 * set. The fermata text content represents the shape of the
 * fermata sign and may be normal, angled, or square.
 * An empty fermata element represents a normal fermata.
 * The fermata type is upright if not specified.
 */
mixin template IFermata() {
    mixin IPrintStyle;
    NormalAngledSquare shape;
    UprightInverted type;
}

/**
 * Fermata and wavy-line elements can be applied both to
 * notes and to measures, so they are defined here. Wavy
 * lines are one way to indicate trills; when used with a
 * measure element, they should always have type="continue"
 * 
 * set. The fermata text content represents the shape of the
 * fermata sign and may be normal, angled, or square.
 * An empty fermata element represents a normal fermata.
 * The fermata type is upright if not specified.
 */
export class WavyLine {
    mixin IWavyLine;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundPlacement = false;
        bool foundColor = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * Fermata and wavy-line elements can be applied both to
 * notes and to measures, so they are defined here. Wavy
 * lines are one way to indicate trills; when used with a
 * measure element, they should always have type="continue"
 * 
 * set. The fermata text content represents the shape of the
 * fermata sign and may be normal, angled, or square.
 * An empty fermata element represents a normal fermata.
 * The fermata type is upright if not specified.
 */
mixin template IWavyLine() {
    mixin IPosition;
    mixin IPlacement;
    mixin IColor;
    mixin ITrillSound;
    float number_;
    StartStopContinue type;
}

/**
 * Staff assignment is only needed for music notated on
 * multiple staves. Used by both notes and directions.
 */
alias Staff = float;

/**
 * Segno and coda signs can be associated with a measure
 * or a general musical direction. These are visual
 * indicators only; a sound element is needed to guide
 * playback applications reliably.
 */
export class Segno {
    mixin ISegno;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * Segno and coda signs can be associated with a measure
 * or a general musical direction. These are visual
 * indicators only; a sound element is needed to guide
 * playback applications reliably.
 */
mixin template ISegno() {
    mixin IPrintStyleAlign;
}

/**
 * Segno and coda signs can be associated with a measure
 * or a general musical direction. These are visual
 * indicators only; a sound element is needed to guide
 * playback applications reliably.
 */
export class Coda {
    mixin ICoda;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * Segno and coda signs can be associated with a measure
 * or a general musical direction. These are visual
 * indicators only; a sound element is needed to guide
 * playback applications reliably.
 */
mixin template ICoda() {
    mixin IPrintStyleAlign;
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
export class ActualNotes {
    mixin IActualNotes;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.count = data;
    }
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
mixin template IActualNotes() {
    float count;
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
export class NormalNotes {
    mixin INormalNotes;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.count = data;
    }
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
mixin template INormalNotes() {
    float count;
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
export class NormalDot {
    mixin INormalDot;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * These elements are used both in the time-modification and
 * metronome-tuplet elements. The actual-notes element
 * describes how many notes are played in the time usually
 * occupied by the number of normal-notes. If the normal-notes
 * type is different than the current note type (e.g., a
 * quarter note within an eighth note triplet), then the
 * normal-notes type (e.g. eighth) is specified in the
 * normal-type and normal-dot elements. The content of the
 * actual-notes and normal-notes elements ia a non-negative
 * integer.
 */
mixin template INormalDot() {
}

/**
 * Dynamics can be associated either with a note or a general
 * musical direction. To avoid inconsistencies between and
 * amongst the letter abbreviations for dynamics (what is sf
 * vs. sfz, standing alone or with a trailing dynamic that is
 * not always piano), we use the actual letters as the names
 * of these dynamic elements. The other-dynamics element
 * allows other dynamic marks that are not covered here, but
 * many of those should perhaps be included in a more general
 * musical direction element. Dynamics may also be combined as
 * in <sf/><mp/>.
 * 
 * These letter dynamic symbols are separated from crescendo,
 * decrescendo, and wedge indications. Dynamic representation
 * is inconsistent in scores. Many things are assumed by the
 * composer and left out, such as returns to original dynamics.
 * Systematic representations are quite complex: for example,
 * Humdrum has at least 3 representation formats related to
 * dynamics. The MusicXML format captures what is in the score,
 * but does not try to be optimal for analysis or synthesis of
 * dynamics.
 */
export class Dynamics {
    mixin IDynamics;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundPlacement = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "fp") {
                auto data = true;
                this.fp = data;
            }
            if (ch.name.toString == "pp") {
                auto data = true;
                this.pp = data;
            }
            if (ch.name.toString == "ppp") {
                auto data = true;
                this.ppp = data;
            }
            if (ch.name.toString == "fff") {
                auto data = true;
                this.fff = data;
            }
            if (ch.name.toString == "sf") {
                auto data = true;
                this.sf = data;
            }
            if (ch.name.toString == "rf") {
                auto data = true;
                this.rf = data;
            }
            if (ch.name.toString == "mp") {
                auto data = true;
                this.mp = data;
            }
            if (ch.name.toString == "sfpp") {
                auto data = true;
                this.sfpp = data;
            }
            if (ch.name.toString == "f") {
                auto data = true;
                this.f = data;
            }
            if (ch.name.toString == "ffffff") {
                auto data = true;
                this.ffffff = data;
            }
            if (ch.name.toString == "sfz") {
                auto data = true;
                this.sfz = data;
            }
            if (ch.name.toString == "ff") {
                auto data = true;
                this.ff = data;
            }
            if (ch.name.toString == "pppppp") {
                auto data = true;
                this.pppppp = data;
            }
            if (ch.name.toString == "rfz") {
                auto data = true;
                this.rfz = data;
            }
            if (ch.name.toString == "other-dynamics") {
                auto data = getString(ch, true);
                this.otherDynamics = data;
            }
            if (ch.name.toString == "fz") {
                auto data = true;
                this.fz = data;
            }
            if (ch.name.toString == "ppppp") {
                auto data = true;
                this.ppppp = data;
            }
            if (ch.name.toString == "mf") {
                auto data = true;
                this.mf = data;
            }
            if (ch.name.toString == "pppp") {
                auto data = true;
                this.pppp = data;
            }
            if (ch.name.toString == "fffff") {
                auto data = true;
                this.fffff = data;
            }
            if (ch.name.toString == "sffz") {
                auto data = true;
                this.sffz = data;
            }
            if (ch.name.toString == "sfp") {
                auto data = true;
                this.sfp = data;
            }
            if (ch.name.toString == "p") {
                auto data = true;
                this.p = data;
            }
            if (ch.name.toString == "ffff") {
                auto data = true;
                this.ffff = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * Dynamics can be associated either with a note or a general
 * musical direction. To avoid inconsistencies between and
 * amongst the letter abbreviations for dynamics (what is sf
 * vs. sfz, standing alone or with a trailing dynamic that is
 * not always piano), we use the actual letters as the names
 * of these dynamic elements. The other-dynamics element
 * allows other dynamic marks that are not covered here, but
 * many of those should perhaps be included in a more general
 * musical direction element. Dynamics may also be combined as
 * in <sf/><mp/>.
 * 
 * These letter dynamic symbols are separated from crescendo,
 * decrescendo, and wedge indications. Dynamic representation
 * is inconsistent in scores. Many things are assumed by the
 * composer and left out, such as returns to original dynamics.
 * Systematic representations are quite complex: for example,
 * Humdrum has at least 3 representation formats related to
 * dynamics. The MusicXML format captures what is in the score,
 * but does not try to be optimal for analysis or synthesis of
 * dynamics.
 */
mixin template IDynamics() {
    mixin IPrintStyleAlign;
    mixin IPlacement;
    mixin ITextDecoration;
    mixin IEnclosure;
    bool fp;
    bool pp;
    bool ppp;
    bool fff;
    bool sf;
    bool rf;
    bool mp;
    bool sfpp;
    bool f;
    bool ffffff;
    bool sfz;
    bool ff;
    bool pppppp;
    bool rfz;
    string otherDynamics;
    bool fz;
    bool ppppp;
    bool mf;
    bool pppp;
    bool fffff;
    bool sffz;
    bool sfp;
    bool p;
    bool ffff;
}

/**
 * Fingering is typically indicated 1,2,3,4,5. Multiple
 * fingerings may be given, typically to substitute
 * fingerings in the middle of a note. The substitution
 * and alternate values are "no" if the attribute is
 * not present. For guitar and other fretted instruments,
 * the fingering element represents the fretting finger;
 * the pluck element represents the plucking finger.
 */
export class Fingering {
    mixin IFingering;
    this(xmlNodePtr node) {
        bool foundSubstitution = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundAlternate = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "substitution") {
                auto data = getYesNo(ch, true);
                this.substitution = data;
                foundSubstitution = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "alternate") {
                auto data = getYesNo(ch, true);
                this.alternate = data;
                foundAlternate = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.finger = data;
        if (!foundSubstitution) {
            substitution = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundAlternate) {
            alternate = false;
        }
    }
}

/**
 * Fingering is typically indicated 1,2,3,4,5. Multiple
 * fingerings may be given, typically to substitute
 * fingerings in the middle of a note. The substitution
 * and alternate values are "no" if the attribute is
 * not present. For guitar and other fretted instruments,
 * the fingering element represents the fretting finger;
 * the pluck element represents the plucking finger.
 */
mixin template IFingering() {
    mixin IPrintStyle;
    mixin IPlacement;
    bool substitution;
    float finger;
    bool alternate;
}

/**
 * Fret and string are used with tablature notation and chord
 * symbols. Fret numbers start with 0 for an open string and
 * 1 for the first fret. String numbers start with 1 for the
 * highest string. The string element can also be used in
 * regular notation.
 */
export class Fret {
    mixin IFret;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.fret = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Fret and string are used with tablature notation and chord
 * symbols. Fret numbers start with 0 for an open string and
 * 1 for the first fret. String numbers start with 1 for the
 * highest string. The string element can also be used in
 * regular notation.
 */
mixin template IFret() {
    mixin IFont;
    mixin IColor;
    float fret;
}

/**
 * Fret and string are used with tablature notation and chord
 * symbols. Fret numbers start with 0 for an open string and
 * 1 for the first fret. String numbers start with 1 for the
 * highest string. The string element can also be used in
 * regular notation.
 */
export class String {
    mixin IString;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.stringNum = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * Fret and string are used with tablature notation and chord
 * symbols. Fret numbers start with 0 for an open string and
 * 1 for the first fret. String numbers start with 1 for the
 * highest string. The string element can also be used in
 * regular notation.
 */
mixin template IString() {
    mixin IPrintStyle;
    mixin IPlacement;
    float stringNum;
}

/**
 * The tuning-step, tuning-alter, and tuning-octave elements
 * are represented like the step, alter, and octave elements,
 * with different names to reflect their different function.
 * They are used in the staff-tuning and accord elements.
 */
export class TuningAlter {
    mixin ITuningAlter;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.step = data;
    }
}

/**
 * The tuning-step, tuning-alter, and tuning-octave elements
 * are represented like the step, alter, and octave elements,
 * with different names to reflect their different function.
 * They are used in the staff-tuning and accord elements.
 */
mixin template ITuningAlter() {
    string step;
}

/**
 * The tuning-step, tuning-alter, and tuning-octave elements
 * are represented like the step, alter, and octave elements,
 * with different names to reflect their different function.
 * They are used in the staff-tuning and accord elements.
 */
export class TuningOctave {
    mixin ITuningOctave;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.step = data;
    }
}

/**
 * The tuning-step, tuning-alter, and tuning-octave elements
 * are represented like the step, alter, and octave elements,
 * with different names to reflect their different function.
 * They are used in the staff-tuning and accord elements.
 */
mixin template ITuningOctave() {
    string step;
}

/**
 * The display-text element is used for exact formatting of
 * multi-font text in element in display elements such as
 * part-name-display. Language is Italian ("it") by default.
 * Enclosure is none by default.
 */
export class DisplayText {
    mixin IDisplayText;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * The display-text element is used for exact formatting of
 * multi-font text in element in display elements such as
 * part-name-display. Language is Italian ("it") by default.
 * Enclosure is none by default.
 */
mixin template IDisplayText() {
    mixin ITextFormatting;
    string text;
}

/**
 * The accidental-text element is used for exact formatting of
 * accidentals in display elements such as part-name-display.
 * Values are the same as for the accidental element.
 * Enclosure is none by default.
 */
export class AccidentalText {
    mixin IAccidentalText;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * The accidental-text element is used for exact formatting of
 * accidentals in display elements such as part-name-display.
 * Values are the same as for the accidental element.
 * Enclosure is none by default.
 */
mixin template IAccidentalText() {
    mixin ITextFormatting;
    string text;
}

/**
 * The part-name-display and part-abbreviation-display
 * elements are used in both the score.mod and direction.mod
 * files. They allow more precise control of how part names
 * and abbreviations appear throughout a score. The
 * print-object attributes can be used to determine what,
 * if anything, is printed at the start of each system.
 * Formatting specified in the part-name-display and
 * part-abbreviation-display elements override the formatting
 * specified in the part-name and part-abbreviation elements,
 * respectively.
 */
mixin template IPartNameDisplay() {
    mixin IPrintObject;
    TextArray name;
}

/**
 * The part-name-display and part-abbreviation-display
 * elements are used in both the score.mod and direction.mod
 * files. They allow more precise control of how part names
 * and abbreviations appear throughout a score. The
 * print-object attributes can be used to determine what,
 * if anything, is printed at the start of each system.
 * Formatting specified in the part-name-display and
 * part-abbreviation-display elements override the formatting
 * specified in the part-name and part-abbreviation elements,
 * respectively.
 */
mixin template IPartAbbreviationDisplay() {
    mixin IPrintObject;
    TextArray name;
}

/**
 * The midi-device content corresponds to the DeviceName
 * meta event in Standard MIDI Files. The optional port
 * attribute is a number from 1 to 16 that can be used
 * with the unofficial MIDI port (or cable) meta event.
 * Unlike the DeviceName meta event, there can be
 * multiple midi-device elements per MusicXML part
 * starting in MusicXML 3.0. The optional id attribute
 * refers to the score-instrument assigned to this
 * device. If missing, the device assignment affects
 * all score-instrument elements in the score-part.
 */
export class MidiDevice {
    mixin IMidiDevice;
    this(xmlNodePtr node) {
        bool foundDeviceName = false;
        bool foundPort = false;
        bool foundId = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "port") {
                auto data = getNumber(ch, true);
                this.port = data;
                foundPort = true;
            }
            if (ch.name.toString == "id") {
                auto data = getNumber(ch, true);
                this.id = data;
                foundId = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.deviceName = data;
        if (!foundDeviceName) {
            deviceName = "";
        }
        if (!foundPort) {
            port = float.nan;
        }
        if (!foundId) {
            id = float.nan;
        }
    }
}

/**
 * The midi-device content corresponds to the DeviceName
 * meta event in Standard MIDI Files. The optional port
 * attribute is a number from 1 to 16 that can be used
 * with the unofficial MIDI port (or cable) meta event.
 * Unlike the DeviceName meta event, there can be
 * multiple midi-device elements per MusicXML part
 * starting in MusicXML 3.0. The optional id attribute
 * refers to the score-instrument assigned to this
 * device. If missing, the device assignment affects
 * all score-instrument elements in the score-part.
 */
mixin template IMidiDevice() {
    float port;
    string deviceName;
    float id;
}

/**
 * MIDI 1.0 channel numbers range from 1 to 16.
 */
export float MidiChannel(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 16);
    return m;
}

/**
 *  midi 1.0 bank numbers range from 1 to 16,384. 
 */
export float MidiBank(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 16384);
    return m;
}

/**
 *  MIDI 1.0 program numbers range from 1 to 128. 
 */
export float MidiProgram(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 128);
    return m;
}

/**
 * For unpitched instruments, specify a MIDI 1.0 note number
 * ranging from 1 to 128. It is usually used with MIDI banks for
 * percussion. Note that MIDI 1.0 note numbers are generally
 * specified from 0 to 127 rather than the 1 to 128 numbering
 * used in this element.
 */
export float MidiUnpitched(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 128);
    return m;
}

/**
 * The volume value is a percentage of the maximum
 * ranging from 0 to 100, with decimal values allowed.
 * This corresponds to a scaling value for the MIDI 1.0
 * channel volume controller.
 */
export float Volume(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= 1 && m <= 100);
    return m;
}

/**
 * Pan and elevation allow placing of sound in a 3-D space
 * relative to the listener. Both are expressed in degrees
 * ranging from -180 to 180. For pan, 0 is straight ahead,
 * -90 is hard left, 90 is hard right, and -180 and 180
 * are directly behind the listener. For elevation, 0 is
 * level with the listener, 90 is directly above, and -90
 * is directly below.
 */
export float Pan(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= -180 && m <= 180);
    return m;
}

/**
 * Pan and elevation allow placing of sound in a 3-D space
 * relative to the listener. Both are expressed in degrees
 * ranging from -180 to 180. For pan, 0 is straight ahead,
 * -90 is hard left, 90 is hard right, and -180 and 180
 * are directly behind the listener. For elevation, 0 is
 * level with the listener, 90 is directly above, and -90
 * is directly below.
 */
export float Elevation(xmlNodePtr p) {
    float m = getNumber(p, true);
    assert(m >= -180 && m <= 180);
    return m;
}

/**
 * The midi-instrument element can be a part of either
 * the score-instrument element at the start of a part,
 * or the sound element within a part. The id attribute
 * refers to the score-instrument affected by the change.
 */
export class MidiInstrument {
    mixin IMidiInstrument;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "midi-unpitched") {
                auto data = getNumber(ch, true);
                this.midiUnpitched = data;
            }
            if (ch.name.toString == "volume") {
                auto data = getNumber(ch, true);
                this.volume = data;
            }
            if (ch.name.toString == "pan") {
                auto data = getNumber(ch, true);
                this.pan = data;
            }
            if (ch.name.toString == "elevation") {
                auto data = getNumber(ch, true);
                this.elevation = data;
            }
            if (ch.name.toString == "midi-bank") {
                auto data = getNumber(ch, true);
                this.midiBank = data;
            }
            if (ch.name.toString == "midi-program") {
                auto data = getNumber(ch, true);
                this.midiProgram = data;
            }
            if (ch.name.toString == "midi-channel") {
                auto data = getNumber(ch, true);
                this.midiChannel = data;
            }
            if (ch.name.toString == "midi-name") {
                auto data = getString(ch, true);
                this.midiName = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "id") {
                auto data = getString(ch, true);
                this.id = data;
            }
        }
    }
}

/**
 * The midi-instrument element can be a part of either
 * the score-instrument element at the start of a part,
 * or the sound element within a part. The id attribute
 * refers to the score-instrument affected by the change.
 */
mixin template IMidiInstrument() {
    float midiUnpitched;
    float volume;
    float pan;
    float elevation;
    float midiBank;
    float midiProgram;
    string id;
    float midiChannel;
    string midiName;
}

/**
 * The play element, new in Version 3.0, specifies playback
 * techniques to be used in conjunction with the instrument-sound
 * element. When used as part of a sound element, it applies to
 * all notes going forward in score order. In multi-instrument
 * parts, the affected instrument should be specified using the
 * id attribute. When used as part of a note element, it applies
 * to the current note only.
 */
export class Play {
    mixin IPlay;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "ipa") {
                auto data = getString(ch, true);
                this.ipa = data;
            }
            if (ch.name.toString == "mute") {
                auto data = getString(ch, true);
                this.mute = data;
            }
            if (ch.name.toString == "other-play") {
                auto data = getString(ch, true);
                this.otherPlay = data;
            }
            if (ch.name.toString == "semi-pitched") {
                auto data = getString(ch, true);
                this.semiPitched = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The play element, new in Version 3.0, specifies playback
 * techniques to be used in conjunction with the instrument-sound
 * element. When used as part of a sound element, it applies to
 * all notes going forward in score order. In multi-instrument
 * parts, the affected instrument should be specified using the
 * id attribute. When used as part of a note element, it applies
 * to the current note only.
 */
mixin template IPlay() {
    string ipa;
    string mute;
    string otherPlay;
    string semiPitched;
}

/**
 * A width, in mm. Most widths are in terms of "tenths" rather than millimeters.
 */
alias Millimeters = float;

/**
 * Margins, page sizes, and distances are all measured in
 * tenths to keep MusicXML data in a consistent coordinate
 * system as much as possible. The translation to absolute
 * units is done in the scaling element, which specifies
 * how many millimeters are equal to how many tenths. For
 * a staff height of 7 mm, millimeters would be set to 7
 * while tenths is set to 40. The ability to set a formula
 * rather than a single scaling factor helps avoid roundoff
 * errors.
 */
export class Scaling {
    mixin IScaling;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tenths") {
                auto data = getNumber(ch, true);
                this.tenths = data;
            }
            if (ch.name.toString == "millimeters") {
                auto data = getNumber(ch, true);
                this.millimeters = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Margins, page sizes, and distances are all measured in
 * tenths to keep MusicXML data in a consistent coordinate
 * system as much as possible. The translation to absolute
 * units is done in the scaling element, which specifies
 * how many millimeters are equal to how many tenths. For
 * a staff height of 7 mm, millimeters would be set to 7
 * while tenths is set to 40. The ability to set a formula
 * rather than a single scaling factor helps avoid roundoff
 * errors.
 */
mixin template IScaling() {
    float tenths;
    float millimeters;
}

/**
 * Margin elements are included within many of the larger
 * layout elements.
 */
alias LeftMargin = float;

/**
 * Margin elements are included within many of the larger
 * layout elements.
 */
alias RightMargin = float;

/**
 * Margin elements are included within many of the larger
 * layout elements.
 */
alias TopMargin = float;

/**
 * Margin elements are included within many of the larger
 * layout elements.
 */
alias BottomMargin = float;

/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values. The type is not needed when used as
 * part of a print element. If omitted when used in the
 * defaults element, "both" is the default.
 */
alias PageHeight = float;

/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values. The type is not needed when used as
 * part of a print element. If omitted when used in the
 * defaults element, "both" is the default.
 */
alias PageWidth = float;

export enum OddEvenBoth {
    Both = 2,
    Even = 1,
    Odd = 0
}

OddEvenBoth getOddEvenBoth(T)(T p) {
    string s = getString(p, true);
    if (s == "both") {
        return OddEvenBoth.Both;
    }
    if (s == "even") {
        return OddEvenBoth.Even;
    }
    if (s == "odd") {
        return OddEvenBoth.Odd;
    }
    assert(false, "Not reached");
}
/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values.
 */
export class PageMargins {
    mixin IPageMargins;
    this(xmlNodePtr node) {
        bool foundType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "top-margin") {
                auto data = getNumber(ch, true);
                this.topMargin = data;
            }
            if (ch.name.toString == "left-margin") {
                auto data = getNumber(ch, true);
                this.leftMargin = data;
            }
            if (ch.name.toString == "bottom-margin") {
                auto data = getNumber(ch, true);
                this.bottomMargin = data;
            }
            if (ch.name.toString == "right-margin") {
                auto data = getNumber(ch, true);
                this.rightMargin = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getOddEvenBoth(ch);
                this.type = data;
                foundType = true;
            }
        }
        if (!foundType) {
            type = OddEvenBoth.Both;
        }
    }
}

/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values.
 */
mixin template IPageMargins() {
    float topMargin;
    float leftMargin;
    float bottomMargin;
    OddEvenBoth type;
    float rightMargin;
}

/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values. The type is not needed when used as
 * part of a print element. If omitted when used in the
 * defaults element, "both" is the default.
 */
export class PageLayout {
    mixin IPageLayout;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "page-height") {
                auto data = getNumber(ch, true);
                this.pageHeight = data;
            }
            if (ch.name.toString == "page-width") {
                auto data = getNumber(ch, true);
                this.pageWidth = data;
            }
            if (ch.name.toString == "page-margins") {
                auto data = new PageMargins(ch) ;
                this.pageMargins ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Page layout can be defined both in score-wide defaults
 * and in the print element. Page margins are specified either
 * for both even and odd pages, or via separate odd and even
 * page number values. The type is not needed when used as
 * part of a print element. If omitted when used in the
 * defaults element, "both" is the default.
 */
mixin template IPageLayout() {
    float pageHeight;
    float pageWidth;
    PageMargins[] pageMargins;
}

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
alias SystemDistance = float;

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
alias TopSystemDistance = float;

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
export class SystemLayout {
    mixin ISystemLayout;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "system-dividers") {
                auto data = new SystemDividers(ch) ;
                this.systemDividers = data;
            }
            if (ch.name.toString == "system-margins") {
                auto data = new SystemMargins(ch) ;
                this.systemMargins = data;
            }
            if (ch.name.toString == "system-distance") {
                auto data = getNumber(ch, true);
                this.systemDistance = data;
            }
            if (ch.name.toString == "top-system-distance") {
                auto data = getNumber(ch, true);
                this.topSystemDistance = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
mixin template ISystemLayout() {
    SystemDividers systemDividers;
    SystemMargins systemMargins;
    float systemDistance;
    float topSystemDistance;
}

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
export class SystemMargins {
    mixin ISystemMargins;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "left-margin") {
                auto data = getNumber(ch, true);
                this.leftMargin = data;
            }
            if (ch.name.toString == "right-margin") {
                auto data = getNumber(ch, true);
                this.rightMargin = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * A system is a group of staves that are read and played
 * simultaneously. System layout includes left and right
 * margins, the vertical distance from the previous system,
 * and the presence or absence of system dividers.
 * 
 * Margins are relative to the page margins. Positive values
 * indent and negative values reduce the margin size. The
 * system distance is measured from the bottom line of the
 * previous system to the top line of the current system.
 * It is ignored for the first system on a page. The top
 * system distance is measured from the page's top margin to
 * the top line of the first system. It is ignored for all
 * but the first system on a page.
 * 
 * Sometimes the sum of measure widths in a system may not
 * equal the system width specified by the layout elements due
 * to roundoff or other errors. The behavior when reading
 * MusicXML files in these cases is application-dependent.
 * For instance, applications may find that the system layout
 * data is more reliable than the sum of the measure widths,
 * and adjust the measure widths accordingly.
 * 
 * When used in the layout element, the system-layout element
 * defines a default appearance for all systems in the score.
 * When used in the print element, the system layout element
 * affects the appearance of the current system only. All
 * other systems use the default values provided in the
 * defaults element. If any child elements are missing from
 * the system-layout element in a print element, the values
 * from the defaults element are used there as well.
 */
mixin template ISystemMargins() {
    float leftMargin;
    float rightMargin;
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
export class SystemDividers {
    mixin ISystemDividers;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "right-divider") {
                auto data = new RightDivider(ch) ;
                this.rightDivider = data;
            }
            if (ch.name.toString == "left-divider") {
                auto data = new LeftDivider(ch) ;
                this.leftDivider = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
mixin template ISystemDividers() {
    RightDivider rightDivider;
    LeftDivider leftDivider;
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
export class LeftDivider {
    mixin ILeftDivider;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
mixin template ILeftDivider() {
    mixin IPrintObject;
    mixin IPrintStyleAlign;
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
export class RightDivider {
    mixin IRightDivider;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The system-dividers element indicates the presence or
 * absence of system dividers (also known as system separation
 * marks) between systems displayed on the same page. Dividers
 * on the left and right side of the page are controlled by
 * the left-divider and right-divider elements respectively.
 * The default vertical position is half the system-distance
 * value from the top of the system that is below the divider.
 * The default horizontal position is the left and right
 * system margin, respectively.
 * 
 * When used in the print element, the system-dividers element
 * affects the dividers that would appear between the current
 * system and the previous system.
 */
mixin template IRightDivider() {
    mixin IPrintObject;
    mixin IPrintStyleAlign;
}

/**
 * Staff layout includes the vertical distance from the bottom
 * line of the previous staff in this system to the top line
 * of the staff specified by the number attribute. The
 * optional number attribute refers to staff numbers within
 * the part, from top to bottom on the system. A value of 1
 * is assumed if not present. When used in the defaults
 * element, the values apply to all parts. This value is
 * ignored for the first staff in a system.
 */
alias StaffDistance = float;

/**
 * Staff layout includes the vertical distance from the bottom
 * line of the previous staff in this system to the top line
 * of the staff specified by the number attribute. The
 * optional number attribute refers to staff numbers within
 * the part, from top to bottom on the system. A value of 1
 * is assumed if not present. When used in the defaults
 * element, the values apply to all parts. This value is
 * ignored for the first staff in a system.
 */
export class StaffLayout {
    mixin IStaffLayout;
    this(xmlNodePtr node) {
        bool foundNum = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "staff-distance") {
                auto data = getNumber(ch, true);
                this.staffDistance = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "num") {
                auto data = getNumber(ch, true);
                this.num = data;
                foundNum = true;
            }
        }
        if (!foundNum) {
            num = 1;
        }
    }
}

/**
 * Staff layout includes the vertical distance from the bottom
 * line of the previous staff in this system to the top line
 * of the staff specified by the number attribute. The
 * optional number attribute refers to staff numbers within
 * the part, from top to bottom on the system. A value of 1
 * is assumed if not present. When used in the defaults
 * element, the values apply to all parts. This value is
 * ignored for the first staff in a system.
 */
mixin template IStaffLayout() {
    float staffDistance;
    float num;
}

/**
 * Measure layout includes the horizontal distance from the
 * previous measure. This value is only used for systems
 * where there is horizontal whitespace in the middle of a
 * system, as in systems with codas. To specify the measure
 * width, use the width attribute of the measure element.
 */
alias MeasureDistance = float;

/**
 * Measure layout includes the horizontal distance from the
 * previous measure. This value is only used for systems
 * where there is horizontal whitespace in the middle of a
 * system, as in systems with codas. To specify the measure
 * width, use the width attribute of the measure element.
 */
export class MeasureLayout {
    mixin IMeasureLayout;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "measure-distance") {
                auto data = getNumber(ch, true);
                this.measureDistance = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Measure layout includes the horizontal distance from the
 * previous measure. This value is only used for systems
 * where there is horizontal whitespace in the middle of a
 * system, as in systems with codas. To specify the measure
 * width, use the width attribute of the measure element.
 */
mixin template IMeasureLayout() {
    float measureDistance;
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
export class LineWidth {
    mixin ILineWidth;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.tenths = data;
    }
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
mixin template ILineWidth() {
    float tenths;
    string type;
}

export enum CueGraceLarge {
    Grace = 1,
    Cue = 0,
    Large = 2
}

CueGraceLarge getCueGraceLarge(T)(T p) {
    string s = getString(p, true);
    if (s == "grace") {
        return CueGraceLarge.Grace;
    }
    if (s == "cue") {
        return CueGraceLarge.Cue;
    }
    if (s == "large") {
        return CueGraceLarge.Large;
    }
    assert(false, "Not reached");
}
/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
export class NoteSize {
    mixin INoteSize;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getCueGraceLarge(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.size = data;
    }
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
mixin template INoteSize() {
    float size;
    CueGraceLarge type;
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
export class Distance {
    mixin IDistance;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.tenths = data;
    }
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
mixin template IDistance() {
    float tenths;
    string type;
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
export class Appearance {
    mixin IAppearance;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "line-width") {
                auto data = new LineWidth(ch) ;
                this.lineWidths[popFront((data.type.length ? "_" : "") ~ toCamelCase(data.type))] = data;
            }
            if (ch.name.toString == "distance") {
                auto data = new Distance(ch) ;
                this.distances[popFront((data.type.length ? "_" : "") ~ toCamelCase(data.type))] = data;
            }
            if (ch.name.toString == "other-appearance") {
                auto data = getString(ch, true);
                this.otherAppearances ~= data;
            }
            if (ch.name.toString == "note-size") {
                auto data = new NoteSize(ch) ;
                this.noteSizes[data.type] = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The appearance element controls general graphical
 * settings for the music's final form appearance on a
 * printed page of display. This includes support
 * for line widths, definitions for note sizes, and standard
 * distances between notation elements, plus an extension
 * element for other aspects of appearance.
 * 
 * The line-width element indicates the width of a line type
 * in tenths. The type attribute defines what type of line is
 * being defined. Values include beam, bracket, dashes,
 * enclosure, ending, extend, heavy barline, leger,
 * light barline, octave shift, pedal, slur middle, slur tip,
 * staff, stem, tie middle, tie tip, tuplet bracket, and
 * wedge. The text content is expressed in tenths.
 * 
 * The note-size element indicates the percentage of the
 * regular note size to use for notes with a cue and large
 * size as defined in the type element. The grace type is
 * used for notes of cue size that that include a grace
 * element. The cue type is used for all other notes with
 * cue size, whether defined explicitly or implicitly via a
 * cue element. The large type is used for notes of large
 * size. The text content represent the numeric percentage.
 * A value of 100 would be identical to the size of a regular
 * note as defined by the music font.
 * 
 * The distance element represents standard distances between
 * notation elements in tenths. The type attribute defines what
 * type of distance is being defined. Values include hyphen
 * (for hyphens in lyrics) and beam.
 * 
 * The other-appearance element is used to define any
 * graphical settings not yet in the current version of the
 * MusicXML format. This allows extended representation,
 * though without application interoperability.
 */
mixin template IAppearance() {
    LineWidth[string] lineWidths;
    Distance[string] distances;
    string[] otherAppearances;
    NoteSize[CueGraceLarge] noteSizes;
}

/**
 * The creator element is borrowed from Dublin Core. It is
 * used for the creators of the score. The type attribute is
 * used to distinguish different creative contributions. Thus,
 * there can be multiple creators within an identification.
 */
export class Creator {
    mixin ICreator;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.creator = data;
    }
}

/**
 * The creator element is borrowed from Dublin Core. It is
 * used for the creators of the score. The type attribute is
 * used to distinguish different creative contributions. Thus,
 * there can be multiple creators within an identification.
 */
mixin template ICreator() {
    string creator;
    string type;
}

/**
 * Rights is borrowed from Dublin Core. It contains
 * copyright and other intellectual property notices.
 * Words, music, and derivatives can have different types,
 * so multiple rights tags with different type attributes
 * are supported.
 */
export class Rights {
    mixin IRights;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.rights = data;
    }
}

/**
 * Rights is borrowed from Dublin Core. It contains
 * copyright and other intellectual property notices.
 * Words, music, and derivatives can have different types,
 * so multiple rights tags with different type attributes
 * are supported.
 */
mixin template IRights() {
    string type;
    string rights;
}

/**
 * The software used to encode the music.
 */
export class Encoder {
    mixin IEncoder;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.encoder = data;
    }
}

/**
 * The software used to encode the music.
 */
mixin template IEncoder() {
    string encoder;
    string type;
}

/**
 * 
 * The source for the music that is encoded. This is similar
 * to the Dublin Core source element.
 */
export class Source {
    mixin ISource;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.source = data;
    }
}

/**
 * 
 * The source for the music that is encoded. This is similar
 * to the Dublin Core source element.
 */
mixin template ISource() {
    string source;
}

/**
 * A related resource for the music that is encoded. This is
 * similar to the Dublin Core relation element.
 */
export class Relation {
    mixin IRelation;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
    }
}

/**
 * A related resource for the music that is encoded. This is
 * similar to the Dublin Core relation element.
 */
mixin template IRelation() {
    string type;
    string data;
}

/**
 * If a program has other metadata not yet supported in the
 * MusicXML format, it can go in the miscellaneous area.
 */
export class MiscellaneousField {
    mixin IMiscellaneousField;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "name") {
                auto data = getString(ch, true);
                this.name = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
    }
}

/**
 * If a program has other metadata not yet supported in the
 * MusicXML format, it can go in the miscellaneous area.
 */
mixin template IMiscellaneousField() {
    string data;
    string name;
}

/**
 * 
 * If a program has other metadata not yet supported in the
 * MusicXML format, it can go in the miscellaneous area.
 */
export class Miscellaneous {
    mixin IMiscellaneous;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "miscellaneous-field") {
                auto data = new MiscellaneousField(ch) ;
                this.miscellaneousFields ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * 
 * If a program has other metadata not yet supported in the
 * MusicXML format, it can go in the miscellaneous area.
 */
mixin template IMiscellaneous() {
    MiscellaneousField[] miscellaneousFields;
}

/**
 * 
 * Identification contains basic metadata about the score.
 * It includes the information in MuseData headers that
 * may apply at a score-wide, movement-wide, or part-wide
 * level. The creator, rights, source, and relation elements
 * are based on Dublin Core.
 */
export class Identification {
    mixin IIdentification;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "miscellaneous") {
                auto data = new Miscellaneous(ch) ;
                this.miscellaneous = data;
            }
            if (ch.name.toString == "creator") {
                auto data = new Creator(ch) ;
                this.creators ~= data;
            }
            if (ch.name.toString == "relation") {
                auto data = new Relation(ch) ;
                this.relations ~= data;
            }
            if (ch.name.toString == "rights") {
                auto data = new Rights(ch) ;
                this.rights ~= data;
            }
            if (ch.name.toString == "encoding") {
                auto data = new Encoding(ch) ;
                this.encoding = data;
            }
            if (ch.name.toString == "source") {
                auto data = new Source(ch) ;
                this.source = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * 
 * Identification contains basic metadata about the score.
 * It includes the information in MuseData headers that
 * may apply at a score-wide, movement-wide, or part-wide
 * level. The creator, rights, source, and relation elements
 * are based on Dublin Core.
 */
mixin template IIdentification() {
    Miscellaneous miscellaneous;
    Creator[] creators;
    Relation[] relations;
    Rights[] rights;
    Encoding encoding;
    Source source;
}

/**
 * The supports element indicates if the encoding supports
 * a particular MusicXML element. This is recommended for
 * elements like beam, stem, and accidental, where the
 * absence of an element is ambiguous if you do not know
 * if the encoding supports that element. For Version 2.0,
 * the supports element is expanded to allow programs to
 * indicate support for particular attributes or particular
 * values. This lets applications communicate, for example,
 * that all system and/or page breaks are contained in the
 * MusicXML file.
 */
export class Supports {
    mixin ISupports;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "element") {
                auto data = getString(ch, true);
                this.element = data;
            }
            if (ch.name.toString == "attribute") {
                auto data = getString(ch, true);
                this.attribute = data;
            }
            if (ch.name.toString == "value") {
                auto data = getString(ch, true);
                this.value = data;
            }
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
    }
}

/**
 * The supports element indicates if the encoding supports
 * a particular MusicXML element. This is recommended for
 * elements like beam, stem, and accidental, where the
 * absence of an element is ambiguous if you do not know
 * if the encoding supports that element. For Version 2.0,
 * the supports element is expanded to allow programs to
 * indicate support for particular attributes or particular
 * values. This lets applications communicate, for example,
 * that all system and/or page breaks are contained in the
 * MusicXML file.
 */
mixin template ISupports() {
    string element;
    string attribute;
    string value;
    string type;
}

/**
 * Encoding contains information about who did the digital
 * encoding, when, with what software, and in what aspects.
 */
export class Encoding {
    mixin IEncoding;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "encoding-description") {
                auto data = getString(ch, true);
                this.encodingDescriptions ~= data;
            }
            if (ch.name.toString == "encoding-date") {
                auto data = new EncodingDate(ch) ;
                this.encodingDate = data;
            }
            if (ch.name.toString == "supports") {
                auto data = new Supports(ch) ;
                this.supports[popFront((data.element.length ? "_" : "") ~ toCamelCase(data.element) ~ (data.attribute.length ? "_" : "") ~ toCamelCase(data.attribute))] = data;
            }
            if (ch.name.toString == "encoder") {
                auto data = new Encoder(ch) ;
                this.encoders ~= data;
            }
            if (ch.name.toString == "software") {
                auto data = getString(ch, true);
                this.softwares ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Encoding contains information about who did the digital
 * encoding, when, with what software, and in what aspects.
 */
mixin template IEncoding() {
    string[] encodingDescriptions;
    EncodingDate encodingDate;
    Supports[string] supports;
    Encoder[] encoders;
    string[] softwares;
}

export enum SeparatorType {
    None = 0,
    Horizontal = 1,
    Diagonal = 2,
    Vertical = 3,
    Adjacent = 4
}

SeparatorType getSeparatorType(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return SeparatorType.None;
    }
    if (s == "horizontal") {
        return SeparatorType.Horizontal;
    }
    if (s == "diagonal") {
        return SeparatorType.Diagonal;
    }
    if (s == "vertical") {
        return SeparatorType.Vertical;
    }
    if (s == "adjacent") {
        return SeparatorType.Adjacent;
    }
    assert(false, "Not reached");
}
/**
 * The time-separator entity indicates how to display the
 * arrangement between the beats and beat-type values in a
 * time signature. The default value is none. The horizontal,
 * diagonal, and vertical values represent horizontal, diagonal
 * lower-left to upper-right, and vertical lines respectively.
 * For these values, the beats and beat-type values are arranged
 * on either side of the separator line. The none value represents
 * no separator with the beats and beat-type arranged vertically.
 * The adjacent value represents no separator with the beats and
 * beat-type arranged horizontally.
 */
export class TimeSeparator {
    mixin ITimeSeparator;
    this(xmlNodePtr node) {
        bool foundSeparator = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "separator") {
                auto data = getSeparatorType(ch);
                this.separator = data;
                foundSeparator = true;
            }
        }
        if (!foundSeparator) {
            separator = SeparatorType.None;
        }
    }
}

/**
 * The time-separator entity indicates how to display the
 * arrangement between the beats and beat-type values in a
 * time signature. The default value is none. The horizontal,
 * diagonal, and vertical values represent horizontal, diagonal
 * lower-left to upper-right, and vertical lines respectively.
 * For these values, the beats and beat-type values are arranged
 * on either side of the separator line. The none value represents
 * no separator with the beats and beat-type arranged vertically.
 * The adjacent value represents no separator with the beats and
 * beat-type arranged horizontally.
 */
mixin template ITimeSeparator() {
    SeparatorType separator;
}

export enum TimeSymbolType {
    DottedNote = 4,
    Cut = 1,
    SingleNumber = 2,
    Note = 3,
    Common = 0,
    Normal = 5
}

TimeSymbolType getTimeSymbolType(T)(T p) {
    string s = getString(p, true);
    if (s == "dotted-note") {
        return TimeSymbolType.DottedNote;
    }
    if (s == "cut") {
        return TimeSymbolType.Cut;
    }
    if (s == "single-number") {
        return TimeSymbolType.SingleNumber;
    }
    if (s == "note") {
        return TimeSymbolType.Note;
    }
    if (s == "common") {
        return TimeSymbolType.Common;
    }
    if (s == "normal") {
        return TimeSymbolType.Normal;
    }
    assert(false, "Not reached");
}
/**
 * The time-symbol entity indicates how to display a time
 * signature. The normal value is the usual fractional display,
 * and is the implied symbol type if none is specified. Other
 * options are the common and cut time symbols, as well as a
 * single number with an implied denominator. The note symbol
 * indicates that the beat-type should be represented with
 * the corresponding downstem note rather than a number. The
 * dotted-note symbol indicates that the beat-type should be
 * represented with a dotted downstem note that corresponds to
 * three times the beat-type value, and a numerator that is
 * one third the beats value.
 */
export class TimeSymbol {
    mixin ITimeSymbol;
    this(xmlNodePtr node) {
        bool foundSymbol = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "symbol") {
                auto data = getTimeSymbolType(ch);
                this.symbol = data;
                foundSymbol = true;
            }
        }
        if (!foundSymbol) {
            symbol = TimeSymbolType.Normal;
        }
    }
}

/**
 * The time-symbol entity indicates how to display a time
 * signature. The normal value is the usual fractional display,
 * and is the implied symbol type if none is specified. Other
 * options are the common and cut time symbols, as well as a
 * single number with an implied denominator. The note symbol
 * indicates that the beat-type should be represented with
 * the corresponding downstem note rather than a number. The
 * dotted-note symbol indicates that the beat-type should be
 * represented with a dotted downstem note that corresponds to
 * three times the beat-type value, and a numerator that is
 * one third the beats value.
 */
mixin template ITimeSymbol() {
    TimeSymbolType symbol;
}

export enum CancelLocation {
    Right = 1,
    BeforeBarline = 2,
    Left = 0
}

CancelLocation getCancelLocation(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return CancelLocation.Right;
    }
    if (s == "before-barline") {
        return CancelLocation.BeforeBarline;
    }
    if (s == "left") {
        return CancelLocation.Left;
    }
    assert(false, "Not reached");
}
/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
export class Cancel {
    mixin ICancel;
    this(xmlNodePtr node) {
        bool foundLocation = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "location") {
                auto data = getCancelLocation(ch);
                this.location = data;
                foundLocation = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.fifths = data;
        if (!foundLocation) {
            location = CancelLocation.Left;
        }
    }
}

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
mixin template ICancel() {
    float fifths;
    CancelLocation location;
}

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
alias Fifths = float;

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
export class KeyOctave {
    mixin IKeyOctave;
    this(xmlNodePtr node) {
        bool foundCancel = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "cancel") {
                auto data = getYesNo(ch, true);
                this.cancel = data;
                foundCancel = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.octave = data;
        if (!foundCancel) {
            cancel = false;
        }
    }
}

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
mixin template IKeyOctave() {
    float octave;
    float number_;
    bool cancel;
}

/**
 * Musical notation duration is commonly represented as
 * fractions. The divisions element indicates how many
 * divisions per quarter note are used to indicate a note's
 * duration. For example, if duration = 1 and divisions = 2,
 * this is an eighth note duration. Duration and divisions
 * are used directly for generating sound output, so they
 * must be chosen to take tuplets into account. Using a
 * divisions element lets us use just one number to
 * represent a duration for each note in the score, while
 * retaining the full power of a fractional representation.
 * For maximum compatibility with Standard MIDI Files, the
 * divisions value should not exceed 16383.
 */
alias Divisions = float;

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
export class Key {
    mixin IKey;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "cancel") {
                auto data = new Cancel(ch) ;
                this.cancel = data;
            }
            if (ch.name.toString == "key-step") {
                auto data = getString(ch, true);
                this.keySteps ~= data;
            }
            if (ch.name.toString == "key-octave") {
                auto data = new KeyOctave(ch) ;
                this.keyOctaves ~= data;
            }
            if (ch.name.toString == "fifths") {
                auto data = getNumber(ch, true);
                this.fifths = data;
            }
            if (ch.name.toString == "key-alter") {
                auto data = getString(ch, true);
                this.keyAlters ~= data;
            }
            if (ch.name.toString == "key-accidental") {
                auto data = getString(ch, true);
                this.keyAccidentals ~= data;
            }
            if (ch.name.toString == "mode") {
                auto data = getString(ch, true);
                this.mode = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * Traditional key signatures are represented by the number
 * of flats and sharps, plus an optional mode for major/
 * minor/mode distinctions. Negative numbers are used for
 * flats and positive numbers for sharps, reflecting the
 * key's placement within the circle of fifths (hence the
 * element name). A cancel element indicates that the old
 * key signature should be cancelled before the new one
 * appears. This will always happen when changing to C major
 * or A minor and need not be specified then. The cancel
 * value matches the fifths value of the cancelled key
 * signature (e.g., a cancel of -2 will provide an explicit
 * cancellation for changing from B flat major to F major).
 * The optional location attribute indicates where a key
 * signature cancellation appears relative to a new key
 * signature: to the left, to the right, or before the barline
 * and to the left. It is left by default. For mid-measure key
 * elements, a cancel location of before-barline should be
 * treated like a cancel location of left.
 * 
 * Non-traditional key signatures can be represented using
 * the Humdrum/Scot concept of a list of altered tones.
 * The key-step and key-alter elements are represented the
 * same way as the step and alter elements are in the pitch
 * element in the note.mod file. The optional key-accidental
 * element is represented the same way as the accidental
 * element in the note.mod file. It is used for disambiguating
 * microtonal accidentals. The different element names
 * indicate the different meaning of altering notes in a scale
 * versus altering a sounding pitch.
 * 
 * Valid mode values include major, minor, dorian, phrygian,
 * lydian, mixolydian, aeolian, ionian, locrian, and none.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the key
 * signature applies to all staves in the part.
 * The optional list of key-octave elements is used to specify
 * in which octave each element of the key signature appears.
 * The content specifies the octave value using the same
 * values as the display-octave element. The number attribute
 * is a positive integer that refers to the key signature
 * element in left-to-right order. If the cancel attribute is
 * set to yes, then this number refers to an element specified
 * by the cancel element. It is no by default.
 * 
 * Key signatures appear at the start of each system unless
 * the print-object attribute has been set to "no".
 */
mixin template IKey() {
    mixin IPrintStyle;
    mixin IPrintObject;
    Cancel cancel;
    string[] keySteps;
    KeyOctave[] keyOctaves;
    float number_;
    float fifths;
    string[] keyAlters;
    string[] keyAccidentals;
    string mode;
}

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */
export class Time {
    mixin ITime;
    this(xmlNodePtr node) {
        bool foundSymbol = false;
        bool foundSeparator = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "interchangeable") {
                auto data = new Interchangeable(ch) ;
                this.interchangeables ~= data;
            }
            if (ch.name.toString == "beats") {
                auto data = getString(ch, true);
                this.beats ~= data;
            }
            if (ch.name.toString == "beat-type") {
                auto data = getNumber(ch, true);
                this.beatTypes ~= data;
            }
            if (ch.name.toString == "senza-misura") {
                auto data = true;
                this.senzaMisura = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "symbol") {
                auto data = getTimeSymbolType(ch);
                this.symbol = data;
                foundSymbol = true;
            }
            if (ch.name.toString == "separator") {
                auto data = getSeparatorType(ch);
                this.separator = data;
                foundSeparator = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundSymbol) {
            symbol = TimeSymbolType.Normal;
        }
        if (!foundSeparator) {
            separator = SeparatorType.None;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */
mixin template ITime() {
    mixin ITimeSymbol;
    mixin ITimeSeparator;
    mixin IPrintStyleAlign;
    mixin IPrintObject;
    Interchangeable[] interchangeables;
    string[] beats;
    float[] beatTypes;
    bool senzaMisura;
}

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */
export class Interchangeable {
    mixin IInterchangeable;
    this(xmlNodePtr node) {
        bool foundSymbol = false;
        bool foundSeparator = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "beats") {
                auto data = getString(ch, true);
                this.beats ~= data;
            }
            if (ch.name.toString == "beat-type") {
                auto data = getNumber(ch, true);
                this.beatTypes ~= data;
            }
            if (ch.name.toString == "time-relation") {
                auto data = getString(ch, true);
                this.timeRelation = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "symbol") {
                auto data = getTimeSymbolType(ch);
                this.symbol = data;
                foundSymbol = true;
            }
            if (ch.name.toString == "separator") {
                auto data = getSeparatorType(ch);
                this.separator = data;
                foundSeparator = true;
            }
        }
        if (!foundSymbol) {
            symbol = TimeSymbolType.Normal;
        }
        if (!foundSeparator) {
            separator = SeparatorType.None;
        }
    }
}

/**
 * Time signatures are represented by two elements. The
 * beats element indicates the number of beats, as found in
 * the numerator of a time signature. The beat-type element
 * indicates the beat unit, as found in the denominator of
 * a time signature.
 * 
 * Multiple pairs of beats and beat-type elements are used for
 * composite time signatures with multiple denominators, such
 * as 2/4 + 3/8. A composite such as 3+2/8 requires only one
 * beats/beat-type pair.
 * 
 * The interchangeable element is used to represent the second
 * in a pair of interchangeable dual time signatures, such as
 * the 6/8 in 3/4 (6/8). A separate symbol attribute value is
 * available compared to the time element's symbol attribute,
 * which applies to the first of the dual time signatures.
 * The time-relation element indicates the symbol used to
 * represent the interchangeable aspect of the time signature.
 * Valid values are parentheses, bracket, equals, slash, space,
 * and hyphen.
 * 
 * A senza-misura element explicitly indicates that no time
 * signature is present. The optional element content
 * indicates the symbol to be used, if any, such as an X.
 * The time element's symbol attribute is not used when a
 * senza-misura element is present.
 * 
 * The print-object attribute allows a time signature to be
 * specified but not printed, as is the case for excerpts
 * from the middle of a score. The value is "yes" if
 * not present. The optional number attribute refers to staff
 * numbers within the part, from top to bottom on the system.
 * If absent, the time signature applies to all staves in the
 * part.
 */
mixin template IInterchangeable() {
    mixin ITimeSymbol;
    mixin ITimeSeparator;
    string[] beats;
    float[] beatTypes;
    string timeRelation;
}

/**
 * Staves are used if there is more than one staff
 * represented in the given part (e.g., 2 staves for
 * typical piano parts). If absent, a value of 1 is assumed.
 * Staves are ordered from top to bottom in a part in
 * numerical order, with staff 1 above staff 2.
 */
alias Staves = float;

export enum PartSymbolType {
    None = 0,
    Line = 2,
    Bracket = 3,
    Square = 4,
    Brace = 1
}

PartSymbolType getPartSymbolType(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return PartSymbolType.None;
    }
    if (s == "line") {
        return PartSymbolType.Line;
    }
    if (s == "bracket") {
        return PartSymbolType.Bracket;
    }
    if (s == "square") {
        return PartSymbolType.Square;
    }
    if (s == "brace") {
        return PartSymbolType.Brace;
    }
    assert(false, "Not reached");
}
/**
 * The part-symbol element indicates how a symbol for a
 * multi-staff part is indicated in the score. Values include
 * none, brace, line, bracket, and square; brace is the default.
 * The top-staff and bottom-staff elements are used when the
 * brace does not extend across the entire part. For example, in
 * a 3-staff organ part, the top-staff will typically be 1 for
 * the right hand, while the bottom-staff will typically be 2
 * for the left hand. Staff 3 for the pedals is usually outside
 * the brace. By default, the presence of a part-symbol element
 * that does not extend across the entire part also indicates a
 * corresponding change in the common barlines within a part.
 */
export class PartSymbol {
    mixin IPartSymbol;
    this(xmlNodePtr node) {
        bool foundTopStaff = false;
        bool foundColor = false;
        bool foundBottomStaff = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "top-staff") {
                auto data = getNumber(ch, true);
                this.topStaff = data;
                foundTopStaff = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "bottom-staff") {
                auto data = getNumber(ch, true);
                this.bottomStaff = data;
                foundBottomStaff = true;
            }
        }
        auto ch = node;
        auto data = getPartSymbolType(ch);
        this.type = data;
        if (!foundTopStaff) {
            topStaff = -1;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundBottomStaff) {
            bottomStaff = -1;
        }
    }
}

/**
 * The part-symbol element indicates how a symbol for a
 * multi-staff part is indicated in the score. Values include
 * none, brace, line, bracket, and square; brace is the default.
 * The top-staff and bottom-staff elements are used when the
 * brace does not extend across the entire part. For example, in
 * a 3-staff organ part, the top-staff will typically be 1 for
 * the right hand, while the bottom-staff will typically be 2
 * for the left hand. Staff 3 for the pedals is usually outside
 * the brace. By default, the presence of a part-symbol element
 * that does not extend across the entire part also indicates a
 * corresponding change in the common barlines within a part.
 */
mixin template IPartSymbol() {
    mixin IPosition;
    mixin IColor;
    float topStaff;
    PartSymbolType type;
    float bottomStaff;
}

/**
 * Clefs are represented by the sign, line, and
 * clef-octave-change elements. Sign values include G, F, C,
 * percussion, TAB, jianpu, and none. Line numbers are
 * counted from the bottom of the staff. Standard values are
 * 2 for the G sign (treble clef), 4 for the F sign (bass clef),
 * 3 for the C sign (alto clef) and 5 for TAB (on a 6-line
 * staff). The clef-octave-change element is used for
 * transposing clefs (e.g., a treble clef for tenors would
 * have a clef-octave-change value of -1). The optional
 * number attribute refers to staff numbers within the part,
 * from top to bottom on the system. A value of 1 is
 * assumed if not present.
 * 
 * The jianpu sign indicates that the music that follows
 * should be in jianpu numbered notation, just as the TAB
 * sign indicates that the music that follows should be in
 * tablature notation. Unlike TAB, a jianpu sign does not
 * correspond to a visual clef notation.
 * 
 * Sometimes clefs are added to the staff in non-standard
 * line positions, either to indicate cue passages, or when
 * there are multiple clefs present simultaneously on one
 * staff. In this situation, the additional attribute is set to
 * "yes" and the line value is ignored. The size attribute
 * is used for clefs where the additional attribute is "yes".
 * It is typically used to indicate cue clefs.
 * 
 * Sometimes clefs at the start of a measure need to appear
 * after the barline rather than before, as for cues or for
 * use after a repeated section. The after-barline attribute
 * is set to "yes" in this situation. The attribute is ignored
 * for mid-measure clefs.
 * 
 * Clefs appear at the start of each system unless the
 * print-object attribute has been set to "no" or the
 * additional attribute has been set to "yes".
 */
alias Line = float;

/**
 * Clefs are represented by the sign, line, and
 * clef-octave-change elements. Sign values include G, F, C,
 * percussion, TAB, jianpu, and none. Line numbers are
 * counted from the bottom of the staff. Standard values are
 * 2 for the G sign (treble clef), 4 for the F sign (bass clef),
 * 3 for the C sign (alto clef) and 5 for TAB (on a 6-line
 * staff). The clef-octave-change element is used for
 * transposing clefs (e.g., a treble clef for tenors would
 * have a clef-octave-change value of -1). The optional
 * number attribute refers to staff numbers within the part,
 * from top to bottom on the system. A value of 1 is
 * assumed if not present.
 * 
 * The jianpu sign indicates that the music that follows
 * should be in jianpu numbered notation, just as the TAB
 * sign indicates that the music that follows should be in
 * tablature notation. Unlike TAB, a jianpu sign does not
 * correspond to a visual clef notation.
 * 
 * Sometimes clefs are added to the staff in non-standard
 * line positions, either to indicate cue passages, or when
 * there are multiple clefs present simultaneously on one
 * staff. In this situation, the additional attribute is set to
 * "yes" and the line value is ignored. The size attribute
 * is used for clefs where the additional attribute is "yes".
 * It is typically used to indicate cue clefs.
 * 
 * Sometimes clefs at the start of a measure need to appear
 * after the barline rather than before, as for cues or for
 * use after a repeated section. The after-barline attribute
 * is set to "yes" in this situation. The attribute is ignored
 * for mid-measure clefs.
 * 
 * Clefs appear at the start of each system unless the
 * print-object attribute has been set to "no" or the
 * additional attribute has been set to "yes".
 */
export class Clef {
    mixin IClef;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundSize = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        bool foundAfterBarline = false;
        bool foundAdditional = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "clef-octave-change") {
                auto data = getString(ch, true);
                this.clefOctaveChange = data;
            }
            if (ch.name.toString == "sign") {
                auto data = getString(ch, true);
                this.sign = data;
            }
            if (ch.name.toString == "line") {
                auto data = getNumber(ch, true);
                this.line = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "size") {
                auto data = getSymbolSize(ch);
                this.size = data;
                foundSize = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "after-barline") {
                auto data = getYesNo(ch, true);
                this.afterBarline = data;
                foundAfterBarline = true;
            }
            if (ch.name.toString == "additional") {
                auto data = getYesNo(ch, true);
                this.additional = data;
                foundAdditional = true;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundSize) {
            size = SymbolSize.Full;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundAfterBarline) {
            afterBarline = false;
        }
        if (!foundAdditional) {
            additional = false;
        }
    }
}

/**
 * Clefs are represented by the sign, line, and
 * clef-octave-change elements. Sign values include G, F, C,
 * percussion, TAB, jianpu, and none. Line numbers are
 * counted from the bottom of the staff. Standard values are
 * 2 for the G sign (treble clef), 4 for the F sign (bass clef),
 * 3 for the C sign (alto clef) and 5 for TAB (on a 6-line
 * staff). The clef-octave-change element is used for
 * transposing clefs (e.g., a treble clef for tenors would
 * have a clef-octave-change value of -1). The optional
 * number attribute refers to staff numbers within the part,
 * from top to bottom on the system. A value of 1 is
 * assumed if not present.
 * 
 * The jianpu sign indicates that the music that follows
 * should be in jianpu numbered notation, just as the TAB
 * sign indicates that the music that follows should be in
 * tablature notation. Unlike TAB, a jianpu sign does not
 * correspond to a visual clef notation.
 * 
 * Sometimes clefs are added to the staff in non-standard
 * line positions, either to indicate cue passages, or when
 * there are multiple clefs present simultaneously on one
 * staff. In this situation, the additional attribute is set to
 * "yes" and the line value is ignored. The size attribute
 * is used for clefs where the additional attribute is "yes".
 * It is typically used to indicate cue clefs.
 * 
 * Sometimes clefs at the start of a measure need to appear
 * after the barline rather than before, as for cues or for
 * use after a repeated section. The after-barline attribute
 * is set to "yes" in this situation. The attribute is ignored
 * for mid-measure clefs.
 * 
 * Clefs appear at the start of each system unless the
 * print-object attribute has been set to "no" or the
 * additional attribute has been set to "yes".
 */
mixin template IClef() {
    mixin IPrintStyle;
    mixin IPrintObject;
    string clefOctaveChange;
    string sign;
    float number_;
    SymbolSize size;
    float line;
    bool afterBarline;
    bool additional;
}

/**
 * The staff-details element is used to indicate different
 * types of staves. The staff-type element can be ossia,
 * cue, editorial, regular, or alternate. An alternate staff
 * indicates one that shares the same musical data as the
 * prior staff, but displayed differently (e.g., treble and
 * bass clef, standard notation and tab). The staff-lines
 * element specifies the number of lines for a non 5-line
 * staff. The staff-tuning and capo elements are used to
 * specify tuning when using tablature notation. The optional
 * number attribute specifies the staff number from top to
 * bottom on the system, as with clef. The optional show-frets
 * attribute indicates whether to show tablature frets as
 * numbers (0, 1, 2) or letters (a, b, c). The default choice
 * is numbers. The print-object attribute is used to indicate
 * when a staff is not printed in a part, usually in large
 * scores where empty parts are omitted. It is yes by default.
 * If print-spacing is yes while print-object is no, the score
 * is printed in cutaway format where vertical space is left
 * for the empty part.
 */
alias StaffLines = float;

/**
 * The tuning-step, tuning-alter, and tuning-octave
 * elements are defined in the common.mod file. Staff
 * lines are numbered from bottom to top.
 */
export class StaffTuning {
    mixin IStaffTuning;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tuning-alter") {
                auto data = new TuningAlter(ch) ;
                this.tuningAlter = data;
            }
            if (ch.name.toString == "tuning-step") {
                auto data = getString(ch, true);
                this.tuningStep = data;
            }
            if (ch.name.toString == "tuning-octave") {
                auto data = new TuningOctave(ch) ;
                this.tuningOctave = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line") {
                auto data = getString(ch, true);
                this.line = data;
            }
        }
    }
}

/**
 * The tuning-step, tuning-alter, and tuning-octave
 * elements are defined in the common.mod file. Staff
 * lines are numbered from bottom to top.
 */
mixin template IStaffTuning() {
    TuningAlter tuningAlter;
    string line;
    string tuningStep;
    TuningOctave tuningOctave;
}

/**
 * The staff-size element indicates how large a staff
 * space is on this staff, expressed as a percentage of
 * the work's default scaling. Values less than 100 make
 * the staff space smaller while values over 100 make the
 * staff space larger. A staff-type of cue, ossia, or
 * editorial implies a staff-size of less than 100, but
 * the exact value is implementation-dependent unless
 * specified here. Staff size affects staff height only,
 * not the relationship of the staff to the left and
 * right margins.
 */
alias StaffSize = float;

export enum ShowFretsType {
    Letters = 1,
    Numbers = 0
}

ShowFretsType getShowFretsType(T)(T p) {
    string s = getString(p, true);
    if (s == "letters") {
        return ShowFretsType.Letters;
    }
    if (s == "numbers") {
        return ShowFretsType.Numbers;
    }
    assert(false, "Not reached");
}
/**
 * The staff-details element is used to indicate different
 * types of staves. The staff-type element can be ossia,
 * cue, editorial, regular, or alternate. An alternate staff
 * indicates one that shares the same musical data as the
 * prior staff, but displayed differently (e.g., treble and
 * bass clef, standard notation and tab). The staff-lines
 * element specifies the number of lines for a non 5-line
 * staff. The staff-tuning and capo elements are used to
 * specify tuning when using tablature notation. The optional
 * number attribute specifies the staff number from top to
 * bottom on the system, as with clef. The optional show-frets
 * attribute indicates whether to show tablature frets as
 * numbers (0, 1, 2) or letters (a, b, c). The default choice
 * is numbers. The print-object attribute is used to indicate
 * when a staff is not printed in a part, usually in large
 * scores where empty parts are omitted. It is yes by default.
 * If print-spacing is yes while print-object is no, the score
 * is printed in cutaway format where vertical space is left
 * for the empty part.
 */
export class StaffDetails {
    mixin IStaffDetails;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundPrintObject = false;
        bool foundPrintSpacing = false;
        bool foundShowFets = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "staff-lines") {
                auto data = getNumber(ch, true);
                this.staffLines = data;
            }
            if (ch.name.toString == "staff-tuning") {
                auto data = new StaffTuning(ch) ;
                this.staffTunings ~= data;
            }
            if (ch.name.toString == "staff-size") {
                auto data = getNumber(ch, true);
                this.staffSize = data;
            }
            if (ch.name.toString == "capo") {
                auto data = getString(ch, true);
                this.capo = data;
            }
            if (ch.name.toString == "staff-type") {
                auto data = getString(ch, true);
                this.staffType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "print-spacing") {
                auto data = getYesNo(ch, true);
                this.printSpacing = data;
                foundPrintSpacing = true;
            }
            if (ch.name.toString == "show-fets") {
                auto data = getShowFretsType(ch);
                this.showFets = data;
                foundShowFets = true;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundPrintSpacing) {
            printSpacing = true;
        }
        if (!foundShowFets) {
            showFets = ShowFretsType.Numbers;
        }
    }
}

/**
 * The staff-details element is used to indicate different
 * types of staves. The staff-type element can be ossia,
 * cue, editorial, regular, or alternate. An alternate staff
 * indicates one that shares the same musical data as the
 * prior staff, but displayed differently (e.g., treble and
 * bass clef, standard notation and tab). The staff-lines
 * element specifies the number of lines for a non 5-line
 * staff. The staff-tuning and capo elements are used to
 * specify tuning when using tablature notation. The optional
 * number attribute specifies the staff number from top to
 * bottom on the system, as with clef. The optional show-frets
 * attribute indicates whether to show tablature frets as
 * numbers (0, 1, 2) or letters (a, b, c). The default choice
 * is numbers. The print-object attribute is used to indicate
 * when a staff is not printed in a part, usually in large
 * scores where empty parts are omitted. It is yes by default.
 * If print-spacing is yes while print-object is no, the score
 * is printed in cutaway format where vertical space is left
 * for the empty part.
 */
mixin template IStaffDetails() {
    mixin IPrintObject;
    mixin IPrintSpacing;
    float staffLines;
    StaffTuning[] staffTunings;
    float staffSize;
    string capo;
    float number_;
    ShowFretsType showFets;
    string staffType;
}

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */
export class Double {
    mixin IDouble;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */
mixin template IDouble() {
}

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */
export class Transpose {
    mixin ITranspose;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "diatonic") {
                auto data = getString(ch, true);
                this.diatonic = data;
            }
            if (ch.name.toString == "octave-change") {
                auto data = getString(ch, true);
                this.octaveChange = data;
            }
            if (ch.name.toString == "double") {
                auto data = new Double(ch) ;
                this.double_ = data;
            }
            if (ch.name.toString == "chromatic") {
                auto data = getString(ch, true);
                this.chromatic = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
        }
        if (!foundNumber_) {
            number_ = float.nan;
        }
    }
}

/**
 * If the part is being encoded for a transposing instrument
 * in written vs. concert pitch, the transposition must be
 * encoded in the transpose element. The transpose element
 * represents what must be added to the written pitch to get
 * the correct sounding pitch.
 * 
 * The transposition is represented by chromatic steps
 * (required) and three optional elements: diatonic pitch
 * steps, octave changes, and doubling an octave down. The
 * chromatic and octave-change elements are numeric values
 * added to the encoded pitch data to create the sounding
 * pitch. The diatonic element is also numeric and allows
 * for correct spelling of enharmonic transpositions.
 * 
 * The optional number attribute refers to staff numbers,
 * from top to bottom on the system. If absent, the
 * transposition applies to all staves in the part. Per-staff
 * transposition is most often used in parts that represent
 * multiple instruments.
 */
mixin template ITranspose() {
    float number_;
    string diatonic;
    string octaveChange;
    Double double_;
    string chromatic;
}

/**
 * Directives are like directions, but can be grouped together
 * with attributes for convenience. This is typically used for
 * tempo markings at the beginning of a piece of music. This
 * element has been deprecated in Version 2.0 in favor of
 * the directive attribute for direction elements. Language
 * names come from ISO 639, with optional country subcodes
 * from ISO 3166.
 */
export class Directive {
    mixin IDirective;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Directives are like directions, but can be grouped together
 * with attributes for convenience. This is typically used for
 * tempo markings at the beginning of a piece of music. This
 * element has been deprecated in Version 2.0 in favor of
 * the directive attribute for direction elements. Language
 * names come from ISO 639, with optional country subcodes
 * from ISO 3166.
 */
mixin template IDirective() {
    mixin IPrintStyle;
    string data;
}

/**
 * The slash-type and slash-dot elements are optional children
 * of the beat-repeat and slash elements. They have the same
 * values as the type and dot elements, and define what the
 * beat is for the display of repetition marks. If not present,
 * the beat is based on the current time signature.
 */
export class SlashDot {
    mixin ISlashDot;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The slash-type and slash-dot elements are optional children
 * of the beat-repeat and slash elements. They have the same
 * values as the type and dot elements, and define what the
 * beat is for the display of repetition marks. If not present,
 * the beat is based on the current time signature.
 */
mixin template ISlashDot() {
}

/**
 * The text of the multiple-rest element indicates the number
 * of measures in the multiple rest. Multiple rests may use
 * the 1-bar / 2-bar / 4-bar rest symbols, or a single shape.
 * The use-symbols attribute indicates which to use; it is no
 * if not specified.
 */
export class MultipleRest {
    mixin IMultipleRest;
    this(xmlNodePtr node) {
        bool foundUseSymbols = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "use-symbols") {
                auto data = getYesNo(ch, true);
                this.useSymbols = data;
                foundUseSymbols = true;
            }
        }
        auto ch = node;
        auto data = getNumber(ch, true);
        this.count = data;
        if (!foundUseSymbols) {
            useSymbols = false;
        }
    }
}

/**
 * The text of the multiple-rest element indicates the number
 * of measures in the multiple rest. Multiple rests may use
 * the 1-bar / 2-bar / 4-bar rest symbols, or a single shape.
 * The use-symbols attribute indicates which to use; it is no
 * if not specified.
 */
mixin template IMultipleRest() {
    bool useSymbols;
    float count;
}

/**
 * The measure-repeat and beat-repeat element specify a
 * notation style for repetitions. The actual music being
 * repeated needs to be repeated within the MusicXML file.
 * These elements specify the notation that indicates the
 * repeat.
 * 
 * The measure-repeat element is used for both single and
 * multiple measure repeats. The text of the element indicates
 * the number of measures to be repeated in a single pattern.
 * The slashes attribute specifies the number of slashes to
 * use in the repeat sign. It is 1 if not specified. Both the
 * start and the stop of the measure-repeat must be specified.
 */
export class MeasureRepeat {
    mixin IMeasureRepeat;
    this(xmlNodePtr node) {
        bool foundSlashed = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "slashed") {
                auto data = getNumber(ch, true);
                this.slashed = data;
                foundSlashed = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundSlashed) {
            slashed = 1;
        }
    }
}

/**
 * The measure-repeat and beat-repeat element specify a
 * notation style for repetitions. The actual music being
 * repeated needs to be repeated within the MusicXML file.
 * These elements specify the notation that indicates the
 * repeat.
 * 
 * The measure-repeat element is used for both single and
 * multiple measure repeats. The text of the element indicates
 * the number of measures to be repeated in a single pattern.
 * The slashes attribute specifies the number of slashes to
 * use in the repeat sign. It is 1 if not specified. Both the
 * start and the stop of the measure-repeat must be specified.
 */
mixin template IMeasureRepeat() {
    float slashed;
    string data;
    StartStop type;
}

/**
 * The measure-repeat and beat-repeat element specify a
 * notation style for repetitions. The actual music being
 * repeated needs to be repeated within the MusicXML file.
 * These elements specify the notation that indicates the
 * repeat.
 * 
 * The beat-repeat element is used to indicate that a single
 * beat (but possibly many notes) is repeated. Both the start
 * and stop of the beat being repeated should be specified.
 * The slashes attribute specifies the number of slashes to
 * use in the symbol. The use-dots attribute indicates whether
 * or not to use dots as well (for instance, with mixed rhythm
 * patterns). By default, the value for slashes is 1 and the
 * value for use-dots is no.
 */
export class BeatRepeat {
    mixin IBeatRepeat;
    this(xmlNodePtr node) {
        bool foundUseDots = false;
        bool foundSlases = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "slash-type") {
                auto data = getString(ch, true);
                this.slashType = data;
            }
            if (ch.name.toString == "slash-dot") {
                auto data = new SlashDot(ch) ;
                this.slashDots ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "use-dots") {
                auto data = getYesNo(ch, true);
                this.useDots = data;
                foundUseDots = true;
            }
            if (ch.name.toString == "slases") {
                auto data = getNumber(ch, true);
                this.slases = data;
                foundSlases = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        if (!foundUseDots) {
            useDots = false;
        }
        if (!foundSlases) {
            slases = 1;
        }
    }
}

/**
 * The measure-repeat and beat-repeat element specify a
 * notation style for repetitions. The actual music being
 * repeated needs to be repeated within the MusicXML file.
 * These elements specify the notation that indicates the
 * repeat.
 * 
 * The beat-repeat element is used to indicate that a single
 * beat (but possibly many notes) is repeated. Both the start
 * and stop of the beat being repeated should be specified.
 * The slashes attribute specifies the number of slashes to
 * use in the symbol. The use-dots attribute indicates whether
 * or not to use dots as well (for instance, with mixed rhythm
 * patterns). By default, the value for slashes is 1 and the
 * value for use-dots is no.
 */
mixin template IBeatRepeat() {
    string slashType;
    bool useDots;
    SlashDot[] slashDots;
    float slases;
    StartStop type;
}

/**
 * The slash element is used to indicate that slash notation
 * is to be used. If the slash is on every beat, use-stems is
 * no (the default). To indicate rhythms but not pitches,
 * use-stems is set to yes. The type attribute indicates
 * whether this is the start or stop of a slash notation
 * style. The use-dots attribute works as for the beat-repeat
 * element, and only has effect if use-stems is no.
 */
export class Slash {
    mixin ISlash;
    this(xmlNodePtr node) {
        bool foundUseDots = false;
        bool foundUseStems = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "slash-type") {
                auto data = getString(ch, true);
                this.slashType = data;
            }
            if (ch.name.toString == "slash-dot") {
                auto data = new SlashDot(ch) ;
                this.slashDots ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "use-dots") {
                auto data = getYesNo(ch, true);
                this.useDots = data;
                foundUseDots = true;
            }
            if (ch.name.toString == "use-stems") {
                auto data = getYesNo(ch, true);
                this.useStems = data;
                foundUseStems = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        if (!foundUseDots) {
            useDots = false;
        }
        if (!foundUseStems) {
            useStems = false;
        }
    }
}

/**
 * The slash element is used to indicate that slash notation
 * is to be used. If the slash is on every beat, use-stems is
 * no (the default). To indicate rhythms but not pitches,
 * use-stems is set to yes. The type attribute indicates
 * whether this is the start or stop of a slash notation
 * style. The use-dots attribute works as for the beat-repeat
 * element, and only has effect if use-stems is no.
 */
mixin template ISlash() {
    string slashType;
    bool useDots;
    bool useStems;
    SlashDot[] slashDots;
    StartStop type;
}

/**
 * A measure-style indicates a special way to print partial
 * to multiple measures within a part. This includes multiple
 * rests over several measures, repeats of beats, single, or
 * multiple measures, and use of slash notation.
 * 
 * The multiple-rest and measure-repeat symbols indicate the
 * number of measures covered in the element content. The
 * beat-repeat and slash elements can cover partial measures.
 * All but the multiple-rest element use a type attribute to
 * indicate starting and stopping the use of the style. The
 * optional number attribute specifies the staff number from
 * top to bottom on the system, as with clef.
 */
export class MeasureStyle {
    mixin IMeasureStyle;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "measure-repeat") {
                auto data = new MeasureRepeat(ch) ;
                this.measureRepeat = data;
            }
            if (ch.name.toString == "beat-repeat") {
                auto data = new BeatRepeat(ch) ;
                this.beatRepeat = data;
            }
            if (ch.name.toString == "multiple-rest") {
                auto data = new MultipleRest(ch) ;
                this.multipleRest = data;
            }
            if (ch.name.toString == "slash") {
                auto data = new Slash(ch) ;
                this.slash = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * A measure-style indicates a special way to print partial
 * to multiple measures within a part. This includes multiple
 * rests over several measures, repeats of beats, single, or
 * multiple measures, and use of slash notation.
 * 
 * The multiple-rest and measure-repeat symbols indicate the
 * number of measures covered in the element content. The
 * beat-repeat and slash elements can cover partial measures.
 * All but the multiple-rest element use a type attribute to
 * indicate starting and stopping the use of the style. The
 * optional number attribute specifies the staff number from
 * top to bottom on the system, as with clef.
 */
mixin template IMeasureStyle() {
    mixin IFont;
    mixin IColor;
    MeasureRepeat measureRepeat;
    BeatRepeat beatRepeat;
    MultipleRest multipleRest;
    Slash slash;
    float number_;
}

/**
 * The attributes element contains musical information that
 * typically changes on measure boundaries. This includes
 * key and time signatures, clefs, transpositions, and staving.
 * When attributes are changed mid-measure, it affects the
 * music in score order, not in MusicXML document order.
 */
export class Attributes {
    mixin IAttributes;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "divisions") {
                auto data = getNumber(ch, true);
                this.divisions = data;
            }
            if (ch.name.toString == "part-symbol") {
                auto data = new PartSymbol(ch) ;
                this.partSymbol = data;
            }
            if (ch.name.toString == "clef") {
                auto data = new Clef(ch) ;
                this.clefs ~= data;
            }
            if (ch.name.toString == "measure-style") {
                auto data = new MeasureStyle(ch) ;
                this.measureStyle = data;
            }
            if (ch.name.toString == "time") {
                auto data = new Time(ch) ;
                this.time = data;
            }
            if (ch.name.toString == "staff-details") {
                auto data = new StaffDetails(ch) ;
                this.staffDetails = data;
            }
            if (ch.name.toString == "transpose") {
                auto data = new Transpose(ch) ;
                this.transpose = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "staves") {
                auto data = getNumber(ch, true);
                this.staves = data;
            }
            if (ch.name.toString == "instruments") {
                auto data = getString(ch, true);
                this.instruments = data;
            }
            if (ch.name.toString == "key") {
                auto data = new Key(ch) ;
                this.keySignature = data;
            }
            if (ch.name.toString == "directive") {
                auto data = new Directive(ch) ;
                this.directive = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The attributes element contains musical information that
 * typically changes on measure boundaries. This includes
 * key and time signatures, clefs, transpositions, and staving.
 * When attributes are changed mid-measure, it affects the
 * music in score order, not in MusicXML document order.
 */
mixin template IAttributes() {
    mixin IEditorial;
    float divisions;
    PartSymbol partSymbol;
    Clef[] clefs;
    MeasureStyle measureStyle;
    Time time;
    StaffDetails staffDetails;
    Transpose transpose;
    float staves;
    string instruments;
    Key keySignature;
    Directive directive;
}

/**
 * The cue and grace elements indicate the presence of cue and
 * grace notes. The slash attribute for a grace note is yes for
 * slashed eighth notes. The other grace note attributes come
 * from MuseData sound suggestions. The steal-time-previous
 * attribute indicates the percentage of time to steal from the
 * previous note for the grace note. The steal-time-following
 * attribute indicates the percentage of time to steal from the
 * following note for the grace note, as for appoggiaturas. The
 * make-time attribute indicates to make time, not steal time;
 * the units are in real-time divisions for the grace note.
 */
export class Cue {
    mixin ICue;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The cue and grace elements indicate the presence of cue and
 * grace notes. The slash attribute for a grace note is yes for
 * slashed eighth notes. The other grace note attributes come
 * from MuseData sound suggestions. The steal-time-previous
 * attribute indicates the percentage of time to steal from the
 * previous note for the grace note. The steal-time-following
 * attribute indicates the percentage of time to steal from the
 * following note for the grace note, as for appoggiaturas. The
 * make-time attribute indicates to make time, not steal time;
 * the units are in real-time divisions for the grace note.
 */
mixin template ICue() {
}

/**
 * The cue and grace elements indicate the presence of cue and
 * grace notes. The slash attribute for a grace note is yes for
 * slashed eighth notes. The other grace note attributes come
 * from MuseData sound suggestions. The steal-time-previous
 * attribute indicates the percentage of time to steal from the
 * previous note for the grace note. The steal-time-following
 * attribute indicates the percentage of time to steal from the
 * following note for the grace note, as for appoggiaturas. The
 * make-time attribute indicates to make time, not steal time;
 * the units are in real-time divisions for the grace note.
 */
export class Grace {
    mixin IGrace;
    this(xmlNodePtr node) {
        bool foundSlash = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "make-time") {
                auto data = getString(ch, true);
                this.makeTime = data;
            }
            if (ch.name.toString == "steal-time-previous") {
                auto data = getString(ch, true);
                this.stealTimePrevious = data;
            }
            if (ch.name.toString == "slash") {
                auto data = getYesNo(ch, true);
                this.slash = data;
                foundSlash = true;
            }
            if (ch.name.toString == "steal-time-following") {
                auto data = getString(ch, true);
                this.stealTimeFollowing = data;
            }
        }
        if (!foundSlash) {
            slash = false;
        }
    }
}

/**
 * The cue and grace elements indicate the presence of cue and
 * grace notes. The slash attribute for a grace note is yes for
 * slashed eighth notes. The other grace note attributes come
 * from MuseData sound suggestions. The steal-time-previous
 * attribute indicates the percentage of time to steal from the
 * previous note for the grace note. The steal-time-following
 * attribute indicates the percentage of time to steal from the
 * following note for the grace note, as for appoggiaturas. The
 * make-time attribute indicates to make time, not steal time;
 * the units are in real-time divisions for the grace note.
 */
mixin template IGrace() {
    string makeTime;
    string stealTimePrevious;
    bool slash;
    string stealTimeFollowing;
}

/**
 * The chord element indicates that this note is an additional
 * chord tone with the preceding note. The duration of this
 * note can be no longer than the preceding note. In MuseData,
 * a missing duration indicates the same length as the previous
 * note, but the MusicXML format requires a duration for chord
 * notes too.
 */
export class Chord {
    mixin IChord;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The chord element indicates that this note is an additional
 * chord tone with the preceding note. The duration of this
 * note can be no longer than the preceding note. In MuseData,
 * a missing duration indicates the same length as the previous
 * note, but the MusicXML format requires a duration for chord
 * notes too.
 */
mixin template IChord() {
}

/**
 * The unpitched element indicates musical elements that are
 * notated on the staff but lack definite pitch, such as
 * unpitched percussion and speaking voice. Like notes, it
 * uses step and octave elements to indicate placement on the
 * staff, following the current clef. If percussion clef is
 * used, the display-step and display-octave elements are
 * interpreted as if in treble clef, with a G in octave 4 on
 * line 2. If not present, the note is placed on the middle
 * line of the staff, generally used for a one-line staff.
 */
export class Unpitched {
    mixin IUnpitched;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "display-step") {
                auto data = getString(ch, true);
                this.displayStep = data;
            }
            if (ch.name.toString == "display-octave") {
                auto data = getString(ch, true);
                this.displayOctave = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The unpitched element indicates musical elements that are
 * notated on the staff but lack definite pitch, such as
 * unpitched percussion and speaking voice. Like notes, it
 * uses step and octave elements to indicate placement on the
 * staff, following the current clef. If percussion clef is
 * used, the display-step and display-octave elements are
 * interpreted as if in treble clef, with a G in octave 4 on
 * line 2. If not present, the note is placed on the middle
 * line of the staff, generally used for a one-line staff.
 */
mixin template IUnpitched() {
    string displayStep;
    string displayOctave;
}

alias Alter = float;

alias Octave = float;

/**
 * Pitch is represented as a combination of the step of the
 * diatonic scale, the chromatic alteration, and the octave.
 * The step element uses the English letters A through G.
 * The alter element represents chromatic alteration in
 * number of semitones (e.g., -1 for flat, 1 for sharp).
 * Decimal values like 0.5 (quarter tone sharp) are
 * used for microtones. The octave element is represented
 * by the numbers 0 to 9, where 4 indicates the octave
 * started by middle C.
 */
export class Pitch {
    mixin IPitch;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "alter") {
                auto data = getNumber(ch, true);
                this.alter = data;
            }
            if (ch.name.toString == "step") {
                auto data = getString(ch, true);
                this.step = data;
            }
            if (ch.name.toString == "octave") {
                auto data = getNumber(ch, true);
                this.octave = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Pitch is represented as a combination of the step of the
 * diatonic scale, the chromatic alteration, and the octave.
 * The step element uses the English letters A through G.
 * The alter element represents chromatic alteration in
 * number of semitones (e.g., -1 for flat, 1 for sharp).
 * Decimal values like 0.5 (quarter tone sharp) are
 * used for microtones. The octave element is represented
 * by the numbers 0 to 9, where 4 indicates the octave
 * started by middle C.
 */
mixin template IPitch() {
    float alter;
    string step;
    float octave;
}

/**
 * The common note elements between cue/grace notes and
 * regular (full) notes: pitch, chord, and rest information,
 * but not duration (cue and grace notes do not have
 * duration encoded here). Unpitched elements are used for
 * unpitched percussion, speaking voice, and other musical
 * elements lacking determinate pitch.
 */
export class FullNote {
    mixin IFullNote;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "unpitched") {
                auto data = new Unpitched(ch) ;
                this.unpitched = data;
            }
            if (ch.name.toString == "chord") {
                auto data = new Chord(ch) ;
                this.chord = data;
            }
            if (ch.name.toString == "pitch") {
                auto data = new Pitch(ch) ;
                this.pitch = data;
            }
            if (ch.name.toString == "rest") {
                auto data = new Rest(ch) ;
                this.rest = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The common note elements between cue/grace notes and
 * regular (full) notes: pitch, chord, and rest information,
 * but not duration (cue and grace notes do not have
 * duration encoded here). Unpitched elements are used for
 * unpitched percussion, speaking voice, and other musical
 * elements lacking determinate pitch.
 */
mixin template IFullNote() {
    Unpitched unpitched;
    Chord chord;
    Pitch pitch;
    Rest rest;
}

/**
 * The rest element indicates notated rests or silences. Rest
 * elements are usually empty, but placement on the staff can
 * be specified using display-step and display-octave
 * elements. If the measure attribute is set to yes, it
 * indicates this is a complete measure rest.
 */
export class Rest {
    mixin IRest;
    this(xmlNodePtr node) {
        bool foundMeasure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "display-step") {
                auto data = getString(ch, true);
                this.displayStep = data;
            }
            if (ch.name.toString == "display-octave") {
                auto data = getString(ch, true);
                this.displayOctave = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "measure") {
                auto data = getYesNo(ch, true);
                this.measure = data;
                foundMeasure = true;
            }
        }
        if (!foundMeasure) {
            measure = false;
        }
    }
}

/**
 * The rest element indicates notated rests or silences. Rest
 * elements are usually empty, but placement on the staff can
 * be specified using display-step and display-octave
 * elements. If the measure attribute is set to yes, it
 * indicates this is a complete measure rest.
 */
mixin template IRest() {
    bool measure;
    string displayStep;
    string displayOctave;
}

/**
 * Duration is a positive number specified in division units.
 * This is the intended duration vs. notated duration (for
 * instance, swing eighths vs. even eighths, or differences
 * in dotted notes in Baroque-era music). Differences in
 * duration specific to an interpretation or performance
 * should use the note element's attack and release
 * attributes.
 * 
 * The tie element indicates that a tie begins or ends with
 * this note. If the tie element applies only particular times
 * through a repeat, the time-only attribute indicates which
 * times to apply it. The tie element indicates sound; the tied
 * element indicates notation.
 */
alias Duration = float;

/**
 * Duration is a positive number specified in division units.
 * This is the intended duration vs. notated duration (for
 * instance, swing eighths vs. even eighths, or differences
 * in dotted notes in Baroque-era music). Differences in
 * duration specific to an interpretation or performance
 * should use the note element's attack and release
 * attributes.
 * 
 * The tie element indicates that a tie begins or ends with
 * this note. If the tie element applies only particular times
 * through a repeat, the time-only attribute indicates which
 * times to apply it. The tie element indicates sound; the tied
 * element indicates notation.
 */
export class Tie {
    mixin ITie;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "time-only") {
                auto data = getString(ch, true);
                this.timeOnly = data;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
    }
}

/**
 * Duration is a positive number specified in division units.
 * This is the intended duration vs. notated duration (for
 * instance, swing eighths vs. even eighths, or differences
 * in dotted notes in Baroque-era music). Differences in
 * duration specific to an interpretation or performance
 * should use the note element's attack and release
 * attributes.
 * 
 * The tie element indicates that a tie begins or ends with
 * this note. If the tie element applies only particular times
 * through a repeat, the time-only attribute indicates which
 * times to apply it. The tie element indicates sound; the tied
 * element indicates notation.
 */
mixin template ITie() {
    mixin ITimeOnly;
    StartStop type;
}

/**
 * If multiple score-instruments are specified on a
 * score-part, there should be an instrument element for
 * each note in the part. The id attribute is an IDREF back
 * to the score-instrument ID.
 */
export class Instrument {
    mixin IInstrument;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "id") {
                auto data = getString(ch, true);
                this.id = data;
            }
        }
    }
}

/**
 * If multiple score-instruments are specified on a
 * score-part, there should be an instrument element for
 * each note in the part. The id attribute is an IDREF back
 * to the score-instrument ID.
 */
mixin template IInstrument() {
    string id;
}

/**
 * Notes are the most common type of MusicXML data. The
 * MusicXML format keeps the MuseData distinction between
 * elements used for sound information and elements used for
 * notation information (e.g., tie is used for sound, tied for
 * notation). Thus grace notes do not have a duration element.
 * Cue notes have a duration element, as do forward elements,
 * but no tie elements. Having these two types of information
 * available can make interchange considerably easier, as
 * some programs handle one type of information much more
 * readily than the other.
 */
export class Note {
    mixin INote;
    this(xmlNodePtr node) {
        bool foundAttack = false;
        bool foundEndDynamics = false;
        bool foundPizzicato = false;
        bool foundDynamics = false;
        bool foundRelease = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        bool foundPrintSpacing = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "notehead-text") {
                auto data = new NoteheadText(ch) ;
                this.noteheadText = data;
            }
            if (ch.name.toString == "time-modification") {
                auto data = new TimeModification(ch) ;
                this.timeModification = data;
            }
            if (ch.name.toString == "accidental") {
                auto data = new Accidental(ch) ;
                this.accidental = data;
            }
            if (ch.name.toString == "instrument") {
                auto data = new Instrument(ch) ;
                this.instrument = data;
            }
            if (ch.name.toString == "lyric") {
                auto data = new Lyric(ch) ;
                this.lyrics ~= data;
            }
            if (ch.name.toString == "dot") {
                auto data = new Dot(ch) ;
                this.dots ~= data;
            }
            if (ch.name.toString == "notations") {
                auto data = new Notations(ch) ;
                this.notations ~= data;
            }
            if (ch.name.toString == "stem") {
                auto data = new Stem(ch) ;
                this.stem = data;
            }
            if (ch.name.toString == "type") {
                auto data = new Type(ch) ;
                this.noteType = data;
            }
            if (ch.name.toString == "cue") {
                auto data = new Cue(ch) ;
                this.cue = data;
            }
            if (ch.name.toString == "duration") {
                auto data = getNumber(ch, true);
                this.duration = data;
            }
            if (ch.name.toString == "tie") {
                auto data = new Tie(ch) ;
                this.ties ~= data;
            }
            if (ch.name.toString == "play") {
                auto data = new Play(ch) ;
                this.play = data;
            }
            if (ch.name.toString == "staff") {
                auto data = getNumber(ch, true);
                this.staff = data;
            }
            if (ch.name.toString == "grace") {
                auto data = new Grace(ch) ;
                this.grace = data;
            }
            if (ch.name.toString == "notehead") {
                auto data = new Notehead(ch) ;
                this.notehead = data;
            }
            if (ch.name.toString == "voice") {
                auto data = getNumber(ch, true);
                this.voice = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "unpitched") {
                auto data = new Unpitched(ch) ;
                this.unpitched = data;
            }
            if (ch.name.toString == "chord") {
                auto data = new Chord(ch) ;
                this.chord = data;
            }
            if (ch.name.toString == "pitch") {
                auto data = new Pitch(ch) ;
                this.pitch = data;
            }
            if (ch.name.toString == "rest") {
                auto data = new Rest(ch) ;
                this.rest = data;
            }
            if (ch.name.toString == "beam") {
                auto data = new Beam(ch) ;
                this.beams ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "attack") {
                auto data = getNumber(ch, true);
                this.attack = data;
                foundAttack = true;
            }
            if (ch.name.toString == "end-dynamics") {
                auto data = getNumber(ch, true);
                this.endDynamics = data;
                foundEndDynamics = true;
            }
            if (ch.name.toString == "pizzicato") {
                auto data = getYesNo(ch, true);
                this.pizzicato = data;
                foundPizzicato = true;
            }
            if (ch.name.toString == "dynamics") {
                auto data = getNumber(ch, true);
                this.dynamics = data;
                foundDynamics = true;
            }
            if (ch.name.toString == "release") {
                auto data = getNumber(ch, true);
                this.release = data;
                foundRelease = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-dot") {
                auto data = getYesNo(ch, true);
                this.printDot = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "print-spacing") {
                auto data = getYesNo(ch, true);
                this.printSpacing = data;
                foundPrintSpacing = true;
            }
            if (ch.name.toString == "print-lyric") {
                auto data = getYesNo(ch, true);
                this.printLyric = data;
            }
            if (ch.name.toString == "time-only") {
                auto data = getString(ch, true);
                this.timeOnly = data;
            }
        }
        if (!foundAttack) {
            attack = float.nan;
        }
        if (!foundEndDynamics) {
            endDynamics = 90;
        }
        if (!foundPizzicato) {
            pizzicato = false;
        }
        if (!foundDynamics) {
            dynamics = 90;
        }
        if (!foundRelease) {
            release = float.nan;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundPrintSpacing) {
            printSpacing = true;
        }
    }
}

/**
 * Notes are the most common type of MusicXML data. The
 * MusicXML format keeps the MuseData distinction between
 * elements used for sound information and elements used for
 * notation information (e.g., tie is used for sound, tied for
 * notation). Thus grace notes do not have a duration element.
 * Cue notes have a duration element, as do forward elements,
 * but no tie elements. Having these two types of information
 * available can make interchange considerably easier, as
 * some programs handle one type of information much more
 * readily than the other.
 */
mixin template INote() {
    mixin IEditorialVoice;
    mixin IPrintStyle;
    mixin IPrintout;
    mixin ITimeOnly;
    mixin IFullNote;
    NoteheadText noteheadText;
    TimeModification timeModification;
    Accidental accidental;
    Instrument instrument;
    float attack;
    float endDynamics;
    Lyric[] lyrics;
    Dot[] dots;
    Notations[] notations;
    Stem stem;
    Type noteType;
    bool pizzicato;
    Cue cue;
    float duration;
    Tie[] ties;
    float dynamics;
    Play play;
    float staff;
    Grace grace;
    Notehead notehead;
    float release;
    Beam[] beams;
}

export enum Count {
    Quarter = 4,
    Breve = 9990,
    Long = 9991,
    _1024th = 1024,
    _32nd = 32,
    _16th = 16,
    Eighth = 8,
    Maxima = 9992,
    _512th = 512,
    _64th = 64,
    _256th = 256,
    _128th = 128,
    Half = 2,
    Whole = 1
}

Count getCount(T)(T p) {
    string s = getString(p, true);
    if (s == "quarter") {
        return Count.Quarter;
    }
    if (s == "breve") {
        return Count.Breve;
    }
    if (s == "long") {
        return Count.Long;
    }
    if (s == "1024th") {
        return Count._1024th;
    }
    if (s == "32nd") {
        return Count._32nd;
    }
    if (s == "16th") {
        return Count._16th;
    }
    if (s == "eighth") {
        return Count.Eighth;
    }
    if (s == "maxima") {
        return Count.Maxima;
    }
    if (s == "512th") {
        return Count._512th;
    }
    if (s == "64th") {
        return Count._64th;
    }
    if (s == "256th") {
        return Count._256th;
    }
    if (s == "128th") {
        return Count._128th;
    }
    if (s == "half") {
        return Count.Half;
    }
    if (s == "whole") {
        return Count.Whole;
    }
    assert(false, "Not reached");
}
/**
 * Type indicates the graphic note type, Valid values (from
 * shortest to longest) are 1024th, 512th, 256th, 128th,
 * 64th, 32nd, 16th, eighth, quarter, half, whole, breve,
 * long, and maxima. The size attribute indicates full, cue,
 * or large size, with full the default for regular notes and
 * cue the default for cue and grace notes.
 */
export class Type {
    mixin IType;
    this(xmlNodePtr node) {
        bool foundSize = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "size") {
                auto data = getSymbolSize(ch);
                this.size = data;
                foundSize = true;
            }
        }
        auto ch = node;
        auto data = getCount(ch);
        this.duration = data;
        if (!foundSize) {
            size = SymbolSize.Unspecified;
        }
    }
}

/**
 * Type indicates the graphic note type, Valid values (from
 * shortest to longest) are 1024th, 512th, 256th, 128th,
 * 64th, 32nd, 16th, eighth, quarter, half, whole, breve,
 * long, and maxima. The size attribute indicates full, cue,
 * or large size, with full the default for regular notes and
 * cue the default for cue and grace notes.
 */
mixin template IType() {
    Count duration;
    SymbolSize size;
}

/**
 * One dot element is used for each dot of prolongation.
 * The placement element is used to specify whether the
 * dot should appear above or below the staff line. It is
 * ignored for notes that appear on a staff space.
 */
export class Dot {
    mixin IDot;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * One dot element is used for each dot of prolongation.
 * The placement element is used to specify whether the
 * dot should appear above or below the staff line. It is
 * ignored for notes that appear on a staff space.
 */
mixin template IDot() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export enum MxmlAccidental {
    NaturalFlat = 7,
    SharpUp = 13,
    ThreeQuartersFlat = 10,
    ThreeQuartersSharp = 11,
    QuarterFlat = 8,
    Flat = 2,
    TripleSharp = 18,
    Flat1 = 27,
    Flat2 = 28,
    Flat3 = 29,
    Flat4 = 291,
    TripleFlat = 19,
    Flat5 = 30,
    Sharp = 0,
    QuarterSharp = 9,
    SlashFlat = 21,
    FlatDown = 16,
    NaturalDown = 14,
    SlashQuarterSharp = 19,
    SharpSharp = 4,
    Sharp1 = 23,
    FlatUp = 17,
    Sharp2 = 24,
    Sharp3 = 25,
    DoubleSharp = 3,
    Sharp4 = 251,
    Sharp5 = 26,
    Sori = 31,
    DoubleSlashFlat = 22,
    SharpDown = 12,
    Koron = 32,
    NaturalUp = 15,
    SlashSharp = 20,
    NaturalSharp = 6,
    FlatFlat = 5,
    Natural = 1,
    DoubleFlat = 33
}

MxmlAccidental getMxmlAccidental(T)(T p) {
    string s = getString(p, true);
    if (s == "natural-flat") {
        return MxmlAccidental.NaturalFlat;
    }
    if (s == "sharp-up") {
        return MxmlAccidental.SharpUp;
    }
    if (s == "three-quarters-flat") {
        return MxmlAccidental.ThreeQuartersFlat;
    }
    if (s == "three-quarters-sharp") {
        return MxmlAccidental.ThreeQuartersSharp;
    }
    if (s == "quarter-flat") {
        return MxmlAccidental.QuarterFlat;
    }
    if (s == "flat") {
        return MxmlAccidental.Flat;
    }
    if (s == "triple-sharp") {
        return MxmlAccidental.TripleSharp;
    }
    if (s == "flat-1") {
        return MxmlAccidental.Flat1;
    }
    if (s == "flat-2") {
        return MxmlAccidental.Flat2;
    }
    if (s == "flat-3") {
        return MxmlAccidental.Flat3;
    }
    if (s == "flat-4") {
        return MxmlAccidental.Flat4;
    }
    if (s == "triple-flat") {
        return MxmlAccidental.TripleFlat;
    }
    if (s == "flat-5") {
        return MxmlAccidental.Flat5;
    }
    if (s == "sharp") {
        return MxmlAccidental.Sharp;
    }
    if (s == "quarter-sharp") {
        return MxmlAccidental.QuarterSharp;
    }
    if (s == "slash-flat") {
        return MxmlAccidental.SlashFlat;
    }
    if (s == "flat-down") {
        return MxmlAccidental.FlatDown;
    }
    if (s == "natural-down") {
        return MxmlAccidental.NaturalDown;
    }
    if (s == "slash-quarter-sharp") {
        return MxmlAccidental.SlashQuarterSharp;
    }
    if (s == "sharp-sharp") {
        return MxmlAccidental.SharpSharp;
    }
    if (s == "sharp-1") {
        return MxmlAccidental.Sharp1;
    }
    if (s == "flat-up") {
        return MxmlAccidental.FlatUp;
    }
    if (s == "sharp-2") {
        return MxmlAccidental.Sharp2;
    }
    if (s == "sharp-3") {
        return MxmlAccidental.Sharp3;
    }
    if (s == "double-sharp") {
        return MxmlAccidental.DoubleSharp;
    }
    if (s == "sharp-4") {
        return MxmlAccidental.Sharp4;
    }
    if (s == "sharp-5") {
        return MxmlAccidental.Sharp5;
    }
    if (s == "sori") {
        return MxmlAccidental.Sori;
    }
    if (s == "double-slash-flat") {
        return MxmlAccidental.DoubleSlashFlat;
    }
    if (s == "sharp-down") {
        return MxmlAccidental.SharpDown;
    }
    if (s == "koron") {
        return MxmlAccidental.Koron;
    }
    if (s == "natural-up") {
        return MxmlAccidental.NaturalUp;
    }
    if (s == "slash-sharp") {
        return MxmlAccidental.SlashSharp;
    }
    if (s == "natural-sharp") {
        return MxmlAccidental.NaturalSharp;
    }
    if (s == "flat-flat") {
        return MxmlAccidental.FlatFlat;
    }
    if (s == "natural") {
        return MxmlAccidental.Natural;
    }
    if (s == "double-flat") {
        return MxmlAccidental.DoubleFlat;
    }
    assert(false, "Not reached");
}
/**
 * Actual notated accidentals. Valid values include: sharp,
 * natural, flat, double-sharp, sharp-sharp, flat-flat,
 * natural-sharp, natural-flat, quarter-flat, quarter-sharp,
 * three-quarters-flat, three-quarters-sharp, sharp-down,
 * sharp-up, natural-down, natural-up, flat-down, flat-up,
 * triple-sharp, triple-flat, slash-quarter-sharp,
 * slash-sharp, slash-flat, double-slash-flat, sharp-1,
 * sharp-2, sharp-3, sharp-5, flat-1, flat-2, flat-3,
 * flat-4, sori, and koron.
 * 
 * The quarter- and three-quarters- accidentals are
 * Tartini-style quarter-tone accidentals. The -down and -up
 * accidentals are quarter-tone accidentals that include
 * arrows pointing down or up. The slash- accidentals
 * are used in Turkish classical music. The numbered
 * sharp and flat accidentals are superscripted versions
 * of the accidental signs, used in Turkish folk music.
 * The sori and koron accidentals are microtonal sharp and
 * flat accidentals used in Iranian and Persian music.
 * 
 * Editorial and cautionary indications are indicated
 * by attributes. Values for these attributes are "no" if not
 * present. Specific graphic display such as parentheses,
 * brackets, and size are controlled by the level-display
 * entity defined in the common.mod file.
 */
export class Accidental {
    mixin IAccidental;
    this(xmlNodePtr node) {
        bool foundCautionary = false;
        bool foundBracket = false;
        bool foundSize = false;
        bool foundParentheses = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundEditorial = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "cautionary") {
                auto data = getYesNo(ch, true);
                this.cautionary = data;
                foundCautionary = true;
            }
            if (ch.name.toString == "bracket") {
                auto data = getYesNo(ch, true);
                this.bracket = data;
                foundBracket = true;
            }
            if (ch.name.toString == "size") {
                auto data = getSymbolSize(ch);
                this.size = data;
                foundSize = true;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
                foundParentheses = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "editorial") {
                auto data = getYesNo(ch, true);
                this.editorial = data;
                foundEditorial = true;
            }
        }
        auto ch = node;
        auto data = getMxmlAccidental(ch);
        this.accidental = data;
        if (!foundCautionary) {
            cautionary = false;
        }
        if (!foundBracket) {
            bracket = false;
        }
        if (!foundSize) {
            size = SymbolSize.Unspecified;
        }
        if (!foundParentheses) {
            parentheses = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundEditorial) {
            editorial = false;
        }
    }
}

/**
 * Actual notated accidentals. Valid values include: sharp,
 * natural, flat, double-sharp, sharp-sharp, flat-flat,
 * natural-sharp, natural-flat, quarter-flat, quarter-sharp,
 * three-quarters-flat, three-quarters-sharp, sharp-down,
 * sharp-up, natural-down, natural-up, flat-down, flat-up,
 * triple-sharp, triple-flat, slash-quarter-sharp,
 * slash-sharp, slash-flat, double-slash-flat, sharp-1,
 * sharp-2, sharp-3, sharp-5, flat-1, flat-2, flat-3,
 * flat-4, sori, and koron.
 * 
 * The quarter- and three-quarters- accidentals are
 * Tartini-style quarter-tone accidentals. The -down and -up
 * accidentals are quarter-tone accidentals that include
 * arrows pointing down or up. The slash- accidentals
 * are used in Turkish classical music. The numbered
 * sharp and flat accidentals are superscripted versions
 * of the accidental signs, used in Turkish folk music.
 * The sori and koron accidentals are microtonal sharp and
 * flat accidentals used in Iranian and Persian music.
 * 
 * Editorial and cautionary indications are indicated
 * by attributes. Values for these attributes are "no" if not
 * present. Specific graphic display such as parentheses,
 * brackets, and size are controlled by the level-display
 * entity defined in the common.mod file.
 */
mixin template IAccidental() {
    mixin ILevelDisplay;
    mixin IPrintStyle;
    bool cautionary;
    MxmlAccidental accidental;
    bool editorial;
}

/**
 * Time modification indicates tuplets, double-note tremolos,
 * and other durational changes. A time-modification element
 * shows how the cumulative, sounding effect of tuplets and
 * double-note tremolos compare to the written note type
 * represented by the type and dot elements. The child elements
 * are defined in the common.mod file. Nested tuplets and other
 * notations that use more detailed information need both the
 * time-modification and tuplet elements to be represented
 * accurately.
 */
export class TimeModification {
    mixin ITimeModification;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "actual-notes") {
                auto data = new ActualNotes(ch) ;
                this.actualNotes = data;
            }
            if (ch.name.toString == "normal-type") {
                auto data = getString(ch, true);
                this.normalType = data;
            }
            if (ch.name.toString == "normal-notes") {
                auto data = new NormalNotes(ch) ;
                this.normalNotes = data;
            }
            if (ch.name.toString == "normal-dot") {
                auto data = new NormalDot(ch) ;
                this.normalDots ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Time modification indicates tuplets, double-note tremolos,
 * and other durational changes. A time-modification element
 * shows how the cumulative, sounding effect of tuplets and
 * double-note tremolos compare to the written note type
 * represented by the type and dot elements. The child elements
 * are defined in the common.mod file. Nested tuplets and other
 * notations that use more detailed information need both the
 * time-modification and tuplet elements to be represented
 * accurately.
 */
mixin template ITimeModification() {
    ActualNotes actualNotes;
    string normalType;
    NormalNotes normalNotes;
    NormalDot[] normalDots;
}

export enum StemType {
    None = 2,
    Double = 3,
    Down = 0,
    Up = 1
}

StemType getStemType(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return StemType.None;
    }
    if (s == "double") {
        return StemType.Double;
    }
    if (s == "down") {
        return StemType.Down;
    }
    if (s == "up") {
        return StemType.Up;
    }
    assert(false, "Not reached");
}
/**
 * Stems can be down, up, none, or double. For down and up
 * stems, the position attributes can be used to specify
 * stem length. The relative values specify the end of the
 * stem relative to the program default. Default values
 * specify an absolute end stem position. Negative values of
 * relative-y that would flip a stem instead of shortening
 * it are ignored. A stem element associated with a rest
 * refers to a stemlet.
 */
export class Stem {
    mixin IStem;
    this(xmlNodePtr node) {
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getStemType(ch);
        this.type = data;
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Stems can be down, up, none, or double. For down and up
 * stems, the position attributes can be used to specify
 * stem length. The relative values specify the end of the
 * stem relative to the program default. Default values
 * specify an absolute end stem position. Negative values of
 * relative-y that would flip a stem instead of shortening
 * it are ignored. A stem element associated with a rest
 * refers to a stemlet.
 */
mixin template IStem() {
    mixin IPosition;
    mixin IColor;
    StemType type;
}

export enum NoteheadType {
    InvertedTriangle = 7,
    CircleDot = 14,
    ArrowUp = 9,
    Do = 18,
    Mi = 20,
    Cross = 4,
    Slash = 0,
    Fa = 21,
    Triangle = 1,
    FaUp = 22,
    So = 23,
    LeftTriangle = 15,
    BackSlashed = 11,
    None = 17,
    La = 24,
    Slashed = 10,
    Normal = 12,
    Cluster = 13,
    Ti = 25,
    Re = 19,
    Nrectangle = 16,
    Square = 3,
    ArrowDown = 8,
    X = 5,
    Diamond = 2,
    CircleX = 6
}

NoteheadType getNoteheadType(T)(T p) {
    string s = getString(p, true);
    if (s == "inverted triangle") {
        return NoteheadType.InvertedTriangle;
    }
    if (s == "circle dot") {
        return NoteheadType.CircleDot;
    }
    if (s == "arrow up") {
        return NoteheadType.ArrowUp;
    }
    if (s == "do") {
        return NoteheadType.Do;
    }
    if (s == "mi") {
        return NoteheadType.Mi;
    }
    if (s == "cross") {
        return NoteheadType.Cross;
    }
    if (s == "slash") {
        return NoteheadType.Slash;
    }
    if (s == "fa") {
        return NoteheadType.Fa;
    }
    if (s == "triangle") {
        return NoteheadType.Triangle;
    }
    if (s == "fa up") {
        return NoteheadType.FaUp;
    }
    if (s == "so") {
        return NoteheadType.So;
    }
    if (s == "left triangle") {
        return NoteheadType.LeftTriangle;
    }
    if (s == "back slashed") {
        return NoteheadType.BackSlashed;
    }
    if (s == "none") {
        return NoteheadType.None;
    }
    if (s == "la") {
        return NoteheadType.La;
    }
    if (s == "slashed") {
        return NoteheadType.Slashed;
    }
    if (s == "normal") {
        return NoteheadType.Normal;
    }
    if (s == "cluster") {
        return NoteheadType.Cluster;
    }
    if (s == "ti") {
        return NoteheadType.Ti;
    }
    if (s == "re") {
        return NoteheadType.Re;
    }
    if (s == "nrectangle") {
        return NoteheadType.Nrectangle;
    }
    if (s == "square") {
        return NoteheadType.Square;
    }
    if (s == "arrow down") {
        return NoteheadType.ArrowDown;
    }
    if (s == "x") {
        return NoteheadType.X;
    }
    if (s == "diamond") {
        return NoteheadType.Diamond;
    }
    if (s == "circle-x") {
        return NoteheadType.CircleX;
    }
    assert(false, "Not reached");
}
/**
 * The notehead element indicates shapes other than the open
 * and closed ovals associated with note durations. The element
 * value can be slash, triangle, diamond, square, cross, x,
 * circle-x, inverted triangle, arrow down, arrow up, slashed,
 * back slashed, normal, cluster, circle dot, left triangle,
 * rectangle, or none. For shape note music, the element values
 * do, re, mi, fa, fa up, so, la, and ti are also used,
 * corresponding to Aikin's 7-shape system. The fa up shape is
 * typically used with upstems; the fa shape is typically used
 * with downstems or no stems.
 * 
 * The arrow shapes differ from triangle and inverted triangle
 * by being centered on the stem. Slashed and back slashed
 * notes include both the normal notehead and a slash. The
 * triangle shape has the tip of the triangle pointing up;
 * the inverted triangle shape has the tip of the triangle
 * pointing down. The left triangle shape is a right triangle
 * with the hypotenuse facing up and to the left.
 * 
 * For the enclosed shapes, the default is to be hollow for
 * half notes and longer, and filled otherwise. The filled
 * attribute can be set to change this if needed.
 * 
 * If the parentheses attribute is set to yes, the notehead
 * is parenthesized. It is no by default.
 * 
 * The notehead-text element indicates text that is displayed
 * inside a notehead, as is done in some educational music.
 * It is not needed for the numbers used in tablature or jianpu
 * notation. The presence of a TAB or jianpu clefs is sufficient
 * to indicate that numbers are used. The display-text and
 * accidental-text elements allow display of fully formatted
 * text and accidentals.
 */
export class Notehead {
    mixin INotehead;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "filled") {
                auto data = getYesNo(ch, true);
                this.filled = data;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
            }
        }
        auto ch = node;
        auto data = getNoteheadType(ch);
        this.type = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The notehead element indicates shapes other than the open
 * and closed ovals associated with note durations. The element
 * value can be slash, triangle, diamond, square, cross, x,
 * circle-x, inverted triangle, arrow down, arrow up, slashed,
 * back slashed, normal, cluster, circle dot, left triangle,
 * rectangle, or none. For shape note music, the element values
 * do, re, mi, fa, fa up, so, la, and ti are also used,
 * corresponding to Aikin's 7-shape system. The fa up shape is
 * typically used with upstems; the fa shape is typically used
 * with downstems or no stems.
 * 
 * The arrow shapes differ from triangle and inverted triangle
 * by being centered on the stem. Slashed and back slashed
 * notes include both the normal notehead and a slash. The
 * triangle shape has the tip of the triangle pointing up;
 * the inverted triangle shape has the tip of the triangle
 * pointing down. The left triangle shape is a right triangle
 * with the hypotenuse facing up and to the left.
 * 
 * For the enclosed shapes, the default is to be hollow for
 * half notes and longer, and filled otherwise. The filled
 * attribute can be set to change this if needed.
 * 
 * If the parentheses attribute is set to yes, the notehead
 * is parenthesized. It is no by default.
 * 
 * The notehead-text element indicates text that is displayed
 * inside a notehead, as is done in some educational music.
 * It is not needed for the numbers used in tablature or jianpu
 * notation. The presence of a TAB or jianpu clefs is sufficient
 * to indicate that numbers are used. The display-text and
 * accidental-text elements allow display of fully formatted
 * text and accidentals.
 */
mixin template INotehead() {
    mixin IFont;
    mixin IColor;
    NoteheadType type;
    bool filled;
    bool parentheses;
}

/**
 * The notehead element indicates shapes other than the open
 * and closed ovals associated with note durations. The element
 * value can be slash, triangle, diamond, square, cross, x,
 * circle-x, inverted triangle, arrow down, arrow up, slashed,
 * back slashed, normal, cluster, circle dot, left triangle,
 * rectangle, or none. For shape note music, the element values
 * do, re, mi, fa, fa up, so, la, and ti are also used,
 * corresponding to Aikin's 7-shape system. The fa up shape is
 * typically used with upstems; the fa shape is typically used
 * with downstems or no stems.
 * 
 * The arrow shapes differ from triangle and inverted triangle
 * by being centered on the stem. Slashed and back slashed
 * notes include both the normal notehead and a slash. The
 * triangle shape has the tip of the triangle pointing up;
 * the inverted triangle shape has the tip of the triangle
 * pointing down. The left triangle shape is a right triangle
 * with the hypotenuse facing up and to the left.
 * 
 * For the enclosed shapes, the default is to be hollow for
 * half notes and longer, and filled otherwise. The filled
 * attribute can be set to change this if needed.
 * 
 * If the parentheses attribute is set to yes, the notehead
 * is parenthesized. It is no by default.
 * 
 * The notehead-text element indicates text that is displayed
 * inside a notehead, as is done in some educational music.
 * It is not needed for the numbers used in tablature or jianpu
 * notation. The presence of a TAB or jianpu clefs is sufficient
 * to indicate that numbers are used. The display-text and
 * accidental-text elements allow display of fully formatted
 * text and accidentals.
 */
mixin template INoteheadText() {
    TextArray text;
}

export enum BeamType {
    BackwardHook = 4,
    Begin = 0,
    ForwardHook = 3,
    Continue = 1,
    End = 2
}

BeamType getBeamType(T)(T p) {
    string s = getString(p, true);
    if (s == "backward hook") {
        return BeamType.BackwardHook;
    }
    if (s == "begin") {
        return BeamType.Begin;
    }
    if (s == "forward hook") {
        return BeamType.ForwardHook;
    }
    if (s == "continue") {
        return BeamType.Continue;
    }
    if (s == "end") {
        return BeamType.End;
    }
    assert(false, "Not reached");
}
export enum AccelRitNone {
    Accel = 0,
    None = 2,
    Rit = 1
}

AccelRitNone getAccelRitNone(T)(T p) {
    string s = getString(p, true);
    if (s == "accel") {
        return AccelRitNone.Accel;
    }
    if (s == "none") {
        return AccelRitNone.None;
    }
    if (s == "rit") {
        return AccelRitNone.Rit;
    }
    assert(false, "Not reached");
}
/**
 * Beam types include begin, continue, end, forward hook, and
 * backward hook. Up to eight concurrent beams are available to
 * cover up to 1024th notes, using an enumerated type defined
 * in the common.mod file. Each beam in a note is represented
 * with a separate beam element, starting with the eighth note
 * beam using a number attribute of 1.
 * 
 * Note that the beam number does not distinguish sets of
 * beams that overlap, as it does for slur and other elements.
 * Beaming groups are distinguished by being in different
 * voices and/or the presence or absence of grace and cue
 * elements.
 * 
 * Beams that have a begin value can also have a fan attribute to
 * indicate accelerandos and ritardandos using fanned beams. The
 * fan attribute may also be used with a continue value if the
 * fanning direction changes on that note. The value is "none" if not specified.
 * 
 * The repeater attribute has been deprecated in MusicXML 3.0.
 * Formerly used for tremolos, it needs to be specified with a
 * "yes" value for each beam using it.
 */
export class Beam {
    mixin IBeam;
    this(xmlNodePtr node) {
        bool foundRepeater = false;
        bool foundNumber_ = false;
        bool foundFan = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "repeater") {
                auto data = getYesNo(ch, true);
                this.repeater = data;
                foundRepeater = true;
            }
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "fan") {
                auto data = getAccelRitNone(ch);
                this.fan = data;
                foundFan = true;
            }
        }
        auto ch = node;
        auto data = getBeamType(ch);
        this.type = data;
        if (!foundRepeater) {
            repeater = false;
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundFan) {
            fan = AccelRitNone.None;
        }
    }
}

/**
 * Beam types include begin, continue, end, forward hook, and
 * backward hook. Up to eight concurrent beams are available to
 * cover up to 1024th notes, using an enumerated type defined
 * in the common.mod file. Each beam in a note is represented
 * with a separate beam element, starting with the eighth note
 * beam using a number attribute of 1.
 * 
 * Note that the beam number does not distinguish sets of
 * beams that overlap, as it does for slur and other elements.
 * Beaming groups are distinguished by being in different
 * voices and/or the presence or absence of grace and cue
 * elements.
 * 
 * Beams that have a begin value can also have a fan attribute to
 * indicate accelerandos and ritardandos using fanned beams. The
 * fan attribute may also be used with a continue value if the
 * fanning direction changes on that note. The value is "none" if not specified.
 * 
 * The repeater attribute has been deprecated in MusicXML 3.0.
 * Formerly used for tremolos, it needs to be specified with a
 * "yes" value for each beam using it.
 */
mixin template IBeam() {
    bool repeater;
    float number_;
    BeamType type;
    AccelRitNone fan;
}

/**
 * Notations are musical notations, not XML notations. Multiple
 * notations are allowed in order to represent multiple editorial
 * levels. The print-object attribute, added in Version 3.0,
 * allows notations to represent details of performance technique,
 * such as fingerings, without having them appear in the score.
 */
export class Notations {
    mixin INotations;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "slur") {
                auto data = new Slur(ch) ;
                this.slurs ~= data;
            }
            if (ch.name.toString == "articulations") {
                auto data = new Articulations(ch) ;
                this.articulations ~= data;
            }
            if (ch.name.toString == "slide") {
                auto data = new Slide(ch) ;
                this.slides ~= data;
            }
            if (ch.name.toString == "technical") {
                auto data = new Technical(ch) ;
                this.technicals ~= data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "tied") {
                auto data = new Tied(ch) ;
                this.tieds ~= data;
            }
            if (ch.name.toString == "tuplet") {
                auto data = new Tuplet(ch) ;
                this.tuplets ~= data;
            }
            if (ch.name.toString == "glissando") {
                auto data = new Glissando(ch) ;
                this.glissandos ~= data;
            }
            if (ch.name.toString == "dynamics") {
                auto data = new Dynamics(ch) ;
                this.dynamics ~= data;
            }
            if (ch.name.toString == "fermata") {
                auto data = new Fermata(ch) ;
                this.fermatas ~= data;
            }
            if (ch.name.toString == "accidental-mark") {
                auto data = new AccidentalMark(ch) ;
                this.accidentalMarks ~= data;
            }
            if (ch.name.toString == "ornaments") {
                auto data = new Ornaments(ch) ;
                this.ornaments ~= data;
            }
            if (ch.name.toString == "arpeggiate") {
                auto data = new Arpeggiate(ch) ;
                this.arpeggiates ~= data;
            }
            if (ch.name.toString == "non-arpeggiate") {
                auto data = new NonArpeggiate(ch) ;
                this.nonArpeggiates ~= data;
            }
            if (ch.name.toString == "other-notation") {
                auto data = new OtherNotation(ch) ;
                this.otherNotations ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * Notations are musical notations, not XML notations. Multiple
 * notations are allowed in order to represent multiple editorial
 * levels. The print-object attribute, added in Version 3.0,
 * allows notations to represent details of performance technique,
 * such as fingerings, without having them appear in the score.
 */
mixin template INotations() {
    mixin IEditorial;
    mixin IPrintObject;
    Slur[] slurs;
    Articulations[] articulations;
    Slide[] slides;
    Technical[] technicals;
    Tied[] tieds;
    Tuplet[] tuplets;
    Glissando[] glissandos;
    Dynamics[] dynamics;
    Fermata[] fermatas;
    AccidentalMark[] accidentalMarks;
    Ornaments[] ornaments;
    Arpeggiate[] arpeggiates;
    NonArpeggiate[] nonArpeggiates;
    OtherNotation[] otherNotations;
}

/**
 * The tied element represents the notated tie. The tie element
 * represents the tie sound.
 * 
 * The number attribute is rarely needed to disambiguate ties,
 * since note pitches will usually suffice. The attribute is
 * implied rather than defaulting to 1 as with most elements.
 * It is available for use in more complex tied notation
 * situations.
 */
export class Tied {
    mixin ITied;
    this(xmlNodePtr node) {
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundPlacement = false;
        bool foundOrientation = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "orientation") {
                auto data = getOverUnder(ch);
                this.orientation = data;
                foundOrientation = true;
            }
            if (ch.name.toString == "bezier-x2") {
                auto data = getNumber(ch, true);
                this.bezierX2 = data;
            }
            if (ch.name.toString == "bezier-offset") {
                auto data = getNumber(ch, true);
                this.bezierOffset = data;
            }
            if (ch.name.toString == "bezier-offset2") {
                auto data = getNumber(ch, true);
                this.bezierOffset2 = data;
            }
            if (ch.name.toString == "bezier-x") {
                auto data = getNumber(ch, true);
                this.bezierX = data;
            }
            if (ch.name.toString == "bezier-y") {
                auto data = getNumber(ch, true);
                this.bezierY = data;
            }
            if (ch.name.toString == "bezier-y2") {
                auto data = getNumber(ch, true);
                this.bezierY2 = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
            }
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundOrientation) {
            orientation = OverUnder.Unspecified;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The tied element represents the notated tie. The tie element
 * represents the tie sound.
 * 
 * The number attribute is rarely needed to disambiguate ties,
 * since note pitches will usually suffice. The attribute is
 * implied rather than defaulting to 1 as with most elements.
 * It is available for use in more complex tied notation
 * situations.
 */
mixin template ITied() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPosition;
    mixin IPlacement;
    mixin IOrientation;
    mixin IBezier;
    mixin IColor;
    float number_;
    StartStopContinue type;
}

/**
 * Slur elements are empty. Most slurs are represented with
 * two elements: one with a start type, and one with a stop
 * type. Slurs can add more elements using a continue type.
 * This is typically used to specify the formatting of cross-
 * system slurs, or to specify the shape of very complex slurs.
 */
export class Slur {
    mixin ISlur;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundPlacement = false;
        bool foundOrientation = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "orientation") {
                auto data = getOverUnder(ch);
                this.orientation = data;
                foundOrientation = true;
            }
            if (ch.name.toString == "bezier-x2") {
                auto data = getNumber(ch, true);
                this.bezierX2 = data;
            }
            if (ch.name.toString == "bezier-offset") {
                auto data = getNumber(ch, true);
                this.bezierOffset = data;
            }
            if (ch.name.toString == "bezier-offset2") {
                auto data = getNumber(ch, true);
                this.bezierOffset2 = data;
            }
            if (ch.name.toString == "bezier-x") {
                auto data = getNumber(ch, true);
                this.bezierX = data;
            }
            if (ch.name.toString == "bezier-y") {
                auto data = getNumber(ch, true);
                this.bezierY = data;
            }
            if (ch.name.toString == "bezier-y2") {
                auto data = getNumber(ch, true);
                this.bezierY2 = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundOrientation) {
            orientation = OverUnder.Unspecified;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Slur elements are empty. Most slurs are represented with
 * two elements: one with a start type, and one with a stop
 * type. Slurs can add more elements using a continue type.
 * This is typically used to specify the formatting of cross-
 * system slurs, or to specify the shape of very complex slurs.
 */
mixin template ISlur() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPosition;
    mixin IPlacement;
    mixin IOrientation;
    mixin IBezier;
    mixin IColor;
    float number_;
    StartStopContinue type;
}

export enum ActualBothNone {
    None = 2,
    Both = 1,
    Actual = 0
}

ActualBothNone getActualBothNone(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return ActualBothNone.None;
    }
    if (s == "both") {
        return ActualBothNone.Both;
    }
    if (s == "actual") {
        return ActualBothNone.Actual;
    }
    assert(false, "Not reached");
}
/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class Tuplet {
    mixin ITuplet;
    this(xmlNodePtr node) {
        bool foundBracket = false;
        bool foundShowNumber = false;
        bool foundLineShape = false;
        bool foundPlacement = false;
        bool foundShowType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tuplet-normal") {
                auto data = new TupletNormal(ch) ;
                this.tupletNormal = data;
            }
            if (ch.name.toString == "tuplet-actual") {
                auto data = new TupletActual(ch) ;
                this.tupletActual = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "bracket") {
                auto data = getYesNo(ch, true);
                this.bracket = data;
                foundBracket = true;
            }
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "show-number") {
                auto data = getActualBothNone(ch);
                this.showNumber = data;
                foundShowNumber = true;
            }
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
            if (ch.name.toString == "show-type") {
                auto data = getActualBothNone(ch);
                this.showType = data;
                foundShowType = true;
            }
        }
        if (!foundBracket) {
            bracket = false;
        }
        if (!foundShowNumber) {
            showNumber = ActualBothNone.Actual;
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundShowType) {
            showType = ActualBothNone.None;
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITuplet() {
    mixin ILineShape;
    mixin IPosition;
    mixin IPlacement;
    bool bracket;
    float number_;
    ActualBothNone showNumber;
    TupletNormal tupletNormal;
    StartStop type;
    ActualBothNone showType;
    TupletActual tupletActual;
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class TupletActual {
    mixin ITupletActual;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tuplet-number") {
                auto data = new TupletNumber(ch) ;
                this.tupletNumber = data;
            }
            if (ch.name.toString == "tuplet-dot") {
                auto data = new TupletDot(ch) ;
                this.tupletDots ~= data;
            }
            if (ch.name.toString == "tuplet-type") {
                auto data = new TupletType(ch) ;
                this.tupletType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITupletActual() {
    TupletNumber tupletNumber;
    TupletDot[] tupletDots;
    TupletType tupletType;
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class TupletNormal {
    mixin ITupletNormal;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tuplet-number") {
                auto data = new TupletNumber(ch) ;
                this.tupletNumber = data;
            }
            if (ch.name.toString == "tuplet-dot") {
                auto data = new TupletDot(ch) ;
                this.tupletDots ~= data;
            }
            if (ch.name.toString == "tuplet-type") {
                auto data = new TupletType(ch) ;
                this.tupletType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITupletNormal() {
    TupletNumber tupletNumber;
    TupletDot[] tupletDots;
    TupletType tupletType;
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class TupletNumber {
    mixin ITupletNumber;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITupletNumber() {
    mixin IFont;
    mixin IColor;
    string text;
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class TupletType {
    mixin ITupletType;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITupletType() {
    mixin IFont;
    mixin IColor;
    string text;
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
export class TupletDot {
    mixin ITupletDot;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * A tuplet element is present when a tuplet is to be displayed
 * graphically, in addition to the sound data provided by the
 * time-modification elements. The number attribute is used to
 * distinguish nested tuplets. The bracket attribute is used
 * to indicate the presence of a bracket. If unspecified, the
 * results are implementation-dependent. The line-shape
 * attribute is used to specify whether the bracket is straight
 * or in the older curved or slurred style. It is straight by
 * default.
 * 
 * Whereas a time-modification element shows how the cumulative,
 * sounding effect of tuplets and double-note tremolos compare to
 * the written note type, the tuplet element describes how this
 * is displayed. The tuplet element also provides more detailed
 * representation information than the time-modification element,
 * and is needed to represent nested tuplets and other complex
 * tuplets accurately. The tuplet-actual and tuplet-normal
 * elements provide optional full control over tuplet
 * specifications. Each allows the number and note type
 * (including dots) describing a single tuplet. If any of
 * these elements are absent, their values are based on the
 * time-modification element.
 * 
 * The show-number attribute is used to display either the
 * number of actual notes, the number of both actual and
 * normal notes, or neither. It is actual by default. The
 * show-type attribute is used to display either the actual
 * type, both the actual and normal types, or neither. It is
 * none by default.
 */
mixin template ITupletDot() {
    mixin IFont;
    mixin IColor;
}

/**
 * Glissando and slide elements both indicate rapidly moving
 * from one pitch to the other so that individual notes are not
 * discerned. The distinction is similar to that between NIFF's
 * glissando and portamento elements. A glissando sounds the
 * half notes in between the slide and defaults to a wavy line.
 * A slide is continuous between two notes and defaults to a
 * solid line. The optional text for a glissando or slide is
 * printed alongside the line.
 */
export class Glissando {
    mixin IGlissando;
    this(xmlNodePtr node) {
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundNormal = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
            if (ch.name.toString == "normal") {
                auto data = getNumber(ch, true);
                this.normal = data;
                foundNormal = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.text = data;
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundNormal) {
            normal = 1;
        }
    }
}

/**
 * Glissando and slide elements both indicate rapidly moving
 * from one pitch to the other so that individual notes are not
 * discerned. The distinction is similar to that between NIFF's
 * glissando and portamento elements. A glissando sounds the
 * half notes in between the slide and defaults to a wavy line.
 * A slide is continuous between two notes and defaults to a
 * solid line. The optional text for a glissando or slide is
 * printed alongside the line.
 */
mixin template IGlissando() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    string text;
    StartStop type;
    float normal;
}

/**
 * Glissando and slide elements both indicate rapidly moving
 * from one pitch to the other so that individual notes are not
 * discerned. The distinction is similar to that between NIFF's
 * glissando and portamento elements. A glissando sounds the
 * half notes in between the slide and defaults to a wavy line.
 * A slide is continuous between two notes and defaults to a
 * solid line. The optional text for a glissando or slide is
 * printed alongside the line.
 */
export class Slide {
    mixin ISlide;
    this(xmlNodePtr node) {
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundSecondBeat = false;
        bool foundNormal = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
            if (ch.name.toString == "normal") {
                auto data = getNumber(ch, true);
                this.normal = data;
                foundNormal = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.text = data;
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
        if (!foundNormal) {
            normal = 1;
        }
    }
}

/**
 * Glissando and slide elements both indicate rapidly moving
 * from one pitch to the other so that individual notes are not
 * discerned. The distinction is similar to that between NIFF's
 * glissando and portamento elements. A glissando sounds the
 * half notes in between the slide and defaults to a wavy line.
 * A slide is continuous between two notes and defaults to a
 * solid line. The optional text for a glissando or slide is
 * printed alongside the line.
 */
mixin template ISlide() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IBendSound;
    string text;
    StartStop type;
    float normal;
}

/**
 * The other-notation element is used to define any notations
 * not yet in the MusicXML format. This allows extended
 * representation, though without application interoperability.
 * It handles notations where more specific extension elements
 * such as other-dynamics and other-technical are not
 * appropriate.
 */
export class OtherNotation {
    mixin IOtherNotation;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopSingle(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The other-notation element is used to define any notations
 * not yet in the MusicXML format. This allows extended
 * representation, though without application interoperability.
 * It handles notations where more specific extension elements
 * such as other-dynamics and other-technical are not
 * appropriate.
 */
mixin template IOtherNotation() {
    mixin IPrintObject;
    mixin IPrintStyle;
    mixin IPlacement;
    StartStopSingle type;
    string data;
}

/**
 * The other-direction element is used to define any direction
 * symbols not yet in the current version of the MusicXML
 * format. This allows extended representation, though without
 * application interoperability.
 */
export class OtherDirection {
    mixin IOtherDirection;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The other-direction element is used to define any direction
 * symbols not yet in the current version of the MusicXML
 * format. This allows extended representation, though without
 * application interoperability.
 */
mixin template IOtherDirection() {
    mixin IPrintObject;
    mixin IPrintStyleAlign;
    string data;
}

/**
 * Ornaments can be any of several types, followed optionally
 * by accidentals. The accidental-mark element's content is
 * represented the same as an accidental element, but with a
 * different name to reflect the different musical meaning.
 */
export class Ornaments {
    mixin IOrnaments;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "delayed-inverted-turn") {
                auto data = new DelayedInvertedTurn(ch) ;
                this.delayedInvertedTurn = data;
            }
            if (ch.name.toString == "shake") {
                auto data = new Shake(ch) ;
                this.shake = data;
            }
            if (ch.name.toString == "turn") {
                auto data = new Turn(ch) ;
                this.turn = data;
            }
            if (ch.name.toString == "inverted-turn") {
                auto data = new InvertedTurn(ch) ;
                this.invertedTurn = data;
            }
            if (ch.name.toString == "other-ornament") {
                auto data = new OtherOrnament(ch) ;
                this.otherOrnament = data;
            }
            if (ch.name.toString == "delayed-turn") {
                auto data = new DelayedTurn(ch) ;
                this.delayedTurn = data;
            }
            if (ch.name.toString == "vertical-turn") {
                auto data = new VerticalTurn(ch) ;
                this.verticalTurn = data;
            }
            if (ch.name.toString == "wavy-line") {
                auto data = new WavyLine(ch) ;
                this.wavyLine = data;
            }
            if (ch.name.toString == "tremolo") {
                auto data = new Tremolo(ch) ;
                this.tremolo = data;
            }
            if (ch.name.toString == "accidental-mark") {
                auto data = new AccidentalMark(ch) ;
                this.accidentalMarks ~= data;
            }
            if (ch.name.toString == "trill-mark") {
                auto data = new TrillMark(ch) ;
                this.trillMark = data;
            }
            if (ch.name.toString == "mordent") {
                auto data = new Mordent(ch) ;
                this.mordent = data;
            }
            if (ch.name.toString == "inverted-mordent") {
                auto data = new InvertedMordent(ch) ;
                this.invertedMordent = data;
            }
            if (ch.name.toString == "schleifer") {
                auto data = new Schleifer(ch) ;
                this.schleifer = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * Ornaments can be any of several types, followed optionally
 * by accidentals. The accidental-mark element's content is
 * represented the same as an accidental element, but with a
 * different name to reflect the different musical meaning.
 */
mixin template IOrnaments() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    DelayedInvertedTurn delayedInvertedTurn;
    Shake shake;
    Turn turn;
    InvertedTurn invertedTurn;
    OtherOrnament otherOrnament;
    DelayedTurn delayedTurn;
    VerticalTurn verticalTurn;
    WavyLine wavyLine;
    Tremolo tremolo;
    AccidentalMark[] accidentalMarks;
    TrillMark trillMark;
    Mordent mordent;
    InvertedMordent invertedMordent;
    Schleifer schleifer;
}

export class TrillMark {
    mixin ITrillMark;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

mixin template ITrillMark() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
}

/**
 * the turn and delayed-turn elements are the normal turn
 * shape which goes up then down. the inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. the delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. the vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * if the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class Turn {
    mixin ITurn;
    this(xmlNodePtr node) {
        bool foundSlash = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "slash") {
                auto data = getYesNo(ch, true);
                this.slash = data;
                foundSlash = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundSlash) {
            slash = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * the turn and delayed-turn elements are the normal turn
 * shape which goes up then down. the inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. the delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. the vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * if the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template ITurn() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool slash;
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class DelayedTurn {
    mixin IDelayedTurn;
    this(xmlNodePtr node) {
        bool foundSlash = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "slash") {
                auto data = getYesNo(ch, true);
                this.slash = data;
                foundSlash = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundSlash) {
            slash = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template IDelayedTurn() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool slash;
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class InvertedTurn {
    mixin IInvertedTurn;
    this(xmlNodePtr node) {
        bool foundSlash = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "slash") {
                auto data = getYesNo(ch, true);
                this.slash = data;
                foundSlash = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundSlash) {
            slash = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template IInvertedTurn() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool slash;
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class DelayedInvertedTurn {
    mixin IDelayedInvertedTurn;
    this(xmlNodePtr node) {
        bool foundSlash = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "slash") {
                auto data = getYesNo(ch, true);
                this.slash = data;
                foundSlash = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundSlash) {
            slash = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template IDelayedInvertedTurn() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool slash;
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class VerticalTurn {
    mixin IVerticalTurn;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template IVerticalTurn() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
export class Shake {
    mixin IShake;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The turn and delayed-turn elements are the normal turn
 * shape which goes up then down. The inverted-turn and
 * delayed-inverted-turn elements have the shape which goes
 * down and then up. The delayed-turn and delayed-inverted-turn
 * elements indicate turns that are delayed until the end of the
 * current note. The vertical-turn element has the shape
 * arranged vertically going from upper left to lower right.
 * If the slash attribute is yes, then a vertical line is used
 * to slash the turn; it is no by default.
 */
mixin template IShake() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
}

/**
 * The long attribute for the mordent and inverted-mordent
 * elements is "no" by default. The mordent element represents
 * the sign with the vertical line; the inverted-mordent
 * element represents the sign without the vertical line.
 * The approach and departure attributes are used for compound
 * ornaments, indicating how the beginning and ending of the
 * ornament look relative to the main part of the mordent.
 */
export class Mordent {
    mixin IMordent;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "long") {
                auto data = getYesNo(ch, true);
                this.long_ = data;
            }
            if (ch.name.toString == "approach") {
                auto data = getAboveBelow(ch);
                this.approach = data;
            }
            if (ch.name.toString == "departure") {
                auto data = getAboveBelow(ch);
                this.departure = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The long attribute for the mordent and inverted-mordent
 * elements is "no" by default. The mordent element represents
 * the sign with the vertical line; the inverted-mordent
 * element represents the sign without the vertical line.
 * The approach and departure attributes are used for compound
 * ornaments, indicating how the beginning and ending of the
 * ornament look relative to the main part of the mordent.
 */
mixin template IMordent() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool long_;
    AboveBelow approach;
    AboveBelow departure;
}

/**
 * The long attribute for the mordent and inverted-mordent
 * elements is "no" by default. The mordent element represents
 * the sign with the vertical line; the inverted-mordent
 * element represents the sign without the vertical line.
 * The approach and departure attributes are used for compound
 * ornaments, indicating how the beginning and ending of the
 * ornament look relative to the main part of the mordent.
 */
export class InvertedMordent {
    mixin IInvertedMordent;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundStartNote = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundTrillStep = false;
        bool foundTwoNoteTurn = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "long") {
                auto data = getYesNo(ch, true);
                this.long_ = data;
            }
            if (ch.name.toString == "approach") {
                auto data = getAboveBelow(ch);
                this.approach = data;
            }
            if (ch.name.toString == "departure") {
                auto data = getAboveBelow(ch);
                this.departure = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "start-note") {
                auto data = getUpperMainBelow(ch);
                this.startNote = data;
                foundStartNote = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "trill-step") {
                auto data = getWholeHalfUnison(ch);
                this.trillStep = data;
                foundTrillStep = true;
            }
            if (ch.name.toString == "two-note-turn") {
                auto data = getWholeHalfNone(ch);
                this.twoNoteTurn = data;
                foundTwoNoteTurn = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundStartNote) {
            startNote = UpperMainBelow.Upper;
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundTrillStep) {
            trillStep = WholeHalfUnison.Whole;
        }
        if (!foundTwoNoteTurn) {
            twoNoteTurn = WholeHalfNone.None;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The long attribute for the mordent and inverted-mordent
 * elements is "no" by default. The mordent element represents
 * the sign with the vertical line; the inverted-mordent
 * element represents the sign without the vertical line.
 * The approach and departure attributes are used for compound
 * ornaments, indicating how the beginning and ending of the
 * ornament look relative to the main part of the mordent.
 */
mixin template IInvertedMordent() {
    mixin IPrintStyle;
    mixin IPlacement;
    mixin ITrillSound;
    bool long_;
    AboveBelow approach;
    AboveBelow departure;
}

/**
 * The name for this ornament is based on the German,
 * to avoid confusion with the more common slide element
 * defined earlier.
 */
export class Schleifer {
    mixin ISchleifer;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The name for this ornament is based on the German,
 * to avoid confusion with the more common slide element
 * defined earlier.
 */
mixin template ISchleifer() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The tremolo ornament can be used to indicate either
 * single-note or double-note tremolos. Single-note tremolos
 * use the single type, while double-note tremolos use the
 * start and stop types. The default is "single" for
 * compatibility with Version 1.1. The text of the element
 * indicates the number of tremolo marks and is an integer
 * from 0 to 8. Note that the number of attached beams is
 * not included in this value, but is represented separately
 * using the beam element.
 * 
 * When using double-note tremolos, the duration of each note
 * in the tremolo should correspond to half of the notated type
 * value. A time-modification element should also be added with
 * an actual-notes value of 2 and a normal-notes value of 1. If
 * used within a tuplet, this 2/1 ratio should be multiplied by
 * the existing tuplet ratio.
 * 
 * Using repeater beams for indicating tremolos is deprecated as
 * of MusicXML 3.0.
 */
export class Tremolo {
    mixin ITremolo;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopSingle(ch);
                this.type = data;
                foundType = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundType) {
            type = StartStopSingle.Single;
        }
    }
}

/**
 * The tremolo ornament can be used to indicate either
 * single-note or double-note tremolos. Single-note tremolos
 * use the single type, while double-note tremolos use the
 * start and stop types. The default is "single" for
 * compatibility with Version 1.1. The text of the element
 * indicates the number of tremolo marks and is an integer
 * from 0 to 8. Note that the number of attached beams is
 * not included in this value, but is represented separately
 * using the beam element.
 * 
 * When using double-note tremolos, the duration of each note
 * in the tremolo should correspond to half of the notated type
 * value. A time-modification element should also be added with
 * an actual-notes value of 2 and a normal-notes value of 1. If
 * used within a tuplet, this 2/1 ratio should be multiplied by
 * the existing tuplet ratio.
 * 
 * Using repeater beams for indicating tremolos is deprecated as
 * of MusicXML 3.0.
 */
mixin template ITremolo() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
    StartStopSingle type;
}

/**
 * The other-ornament element is used to define any ornaments
 * not yet in the MusicXML format. This allows extended
 * representation, though without application interoperability.
 */
export class OtherOrnament {
    mixin IOtherOrnament;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopSingle(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The other-ornament element is used to define any ornaments
 * not yet in the MusicXML format. This allows extended
 * representation, though without application interoperability.
 */
mixin template IOtherOrnament() {
    mixin IPrintStyle;
    mixin IPlacement;
    StartStopSingle type;
    string data;
}

/**
 * An accidental-mark can be used as a separate notation or
 * as part of an ornament. When used in an ornament, position
 * and placement are relative to the ornament, not relative to
 * the note.
 */
export class AccidentalMark {
    mixin IAccidentalMark;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.mark = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * An accidental-mark can be used as a separate notation or
 * as part of an ornament. When used in an ornament, position
 * and placement are relative to the ornament, not relative to
 * the note.
 */
mixin template IAccidentalMark() {
    mixin IPrintStyle;
    mixin IPlacement;
    string mark;
}

/**
 * Technical indications give performance information for
 * individual instruments.
 */
export class Technical {
    mixin ITechnical;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "triple-tongue") {
                auto data = new TripleTongue(ch) ;
                this.tripleTongue = data;
            }
            if (ch.name.toString == "toe") {
                auto data = new Toe(ch) ;
                this.toe = data;
            }
            if (ch.name.toString == "hole") {
                auto data = new Hole(ch) ;
                this.hole = data;
            }
            if (ch.name.toString == "hammer-on") {
                auto data = new HammerOn(ch) ;
                this.hammerOn = data;
            }
            if (ch.name.toString == "up-bow") {
                auto data = new UpBow(ch) ;
                this.upBow = data;
            }
            if (ch.name.toString == "down-bow") {
                auto data = new DownBow(ch) ;
                this.downBow = data;
            }
            if (ch.name.toString == "fret") {
                auto data = new Fret(ch) ;
                this.fret = data;
            }
            if (ch.name.toString == "tap") {
                auto data = new Tap(ch) ;
                this.tap = data;
            }
            if (ch.name.toString == "pull-off") {
                auto data = new PullOff(ch) ;
                this.pullOff = data;
            }
            if (ch.name.toString == "handbell") {
                auto data = new Handbell(ch) ;
                this.handbell = data;
            }
            if (ch.name.toString == "bend") {
                auto data = new Bend(ch) ;
                this.bend = data;
            }
            if (ch.name.toString == "thumb-position") {
                auto data = new ThumbPosition(ch) ;
                this.thumbPosition = data;
            }
            if (ch.name.toString == "stopped") {
                auto data = new Stopped(ch) ;
                this.stopped = data;
            }
            if (ch.name.toString == "pluck") {
                auto data = new Pluck(ch) ;
                this.pluck = data;
            }
            if (ch.name.toString == "double-tongue") {
                auto data = new DoubleTongue(ch) ;
                this.doubleTongue = data;
            }
            if (ch.name.toString == "string") {
                auto data = new String(ch) ;
                this.string_ = data;
            }
            if (ch.name.toString == "open-string") {
                auto data = new OpenString(ch) ;
                this.openString = data;
            }
            if (ch.name.toString == "fingernails") {
                auto data = new Fingernails(ch) ;
                this.fingernails = data;
            }
            if (ch.name.toString == "arrow") {
                auto data = new Arrow(ch) ;
                this.arrow = data;
            }
            if (ch.name.toString == "harmonic") {
                auto data = new Harmonic(ch) ;
                this.harmonic = data;
            }
            if (ch.name.toString == "heel") {
                auto data = new Heel(ch) ;
                this.heel = data;
            }
            if (ch.name.toString == "other-technical") {
                auto data = new OtherTechnical(ch) ;
                this.otherTechnical = data;
            }
            if (ch.name.toString == "snap-pizzicato") {
                auto data = new SnapPizzicato(ch) ;
                this.snapPizzicato = data;
            }
            if (ch.name.toString == "fingering") {
                auto data = new Fingering(ch) ;
                this.fingering = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Technical indications give performance information for
 * individual instruments.
 */
mixin template ITechnical() {
    TripleTongue tripleTongue;
    Toe toe;
    Hole hole;
    HammerOn hammerOn;
    UpBow upBow;
    DownBow downBow;
    Fret fret;
    Tap tap;
    PullOff pullOff;
    Handbell handbell;
    Bend bend;
    ThumbPosition thumbPosition;
    Stopped stopped;
    Pluck pluck;
    DoubleTongue doubleTongue;
    String string_;
    OpenString openString;
    Fingernails fingernails;
    Arrow arrow;
    Harmonic harmonic;
    Heel heel;
    OtherTechnical otherTechnical;
    SnapPizzicato snapPizzicato;
    Fingering fingering;
}

/**
 * The up-bow element represents the symbol that is used both
 * for up-bowing on bowed instruments, and up-stroke on plucked
 * instruments.
 */
export class UpBow {
    mixin IUpBow;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The up-bow element represents the symbol that is used both
 * for up-bowing on bowed instruments, and up-stroke on plucked
 * instruments.
 */
mixin template IUpBow() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The down-bow element represents the symbol that is used both
 * for down-bowing on bowed instruments, and down-stroke on
 * plucked instruments.
 */
export class DownBow {
    mixin IDownBow;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The down-bow element represents the symbol that is used both
 * for down-bowing on bowed instruments, and down-stroke on
 * plucked instruments.
 */
mixin template IDownBow() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The harmonic element indicates natural and artificial
 * harmonics. Natural harmonics usually notate the base
 * pitch rather than the sounding pitch. Allowing the type
 * of pitch to be specified, combined with controls for
 * appearance/playback differences, allows both the notation
 * and the sound to be represented. Artificial harmonics can
 * add a notated touching-pitch; the pitch or fret at which
 * the string is touched lightly to produce the harmonic.
 * Artificial pinch harmonics will usually not notate a
 * touching pitch. The attributes for the harmonic element
 * refer to the use of the circular harmonic symbol, typically
 * but not always used with natural harmonics.
 */
export class Harmonic {
    mixin IHarmonic;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "artificial") {
                auto data = true;
                this.artificial = data;
            }
            if (ch.name.toString == "touching-pitch") {
                auto data = true;
                this.touchingPitch = data;
            }
            if (ch.name.toString == "sounding-pitch") {
                auto data = true;
                this.soundingPitch = data;
            }
            if (ch.name.toString == "natural") {
                auto data = true;
                this.natural = data;
            }
            if (ch.name.toString == "base-pitch") {
                auto data = true;
                this.basePitch = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The harmonic element indicates natural and artificial
 * harmonics. Natural harmonics usually notate the base
 * pitch rather than the sounding pitch. Allowing the type
 * of pitch to be specified, combined with controls for
 * appearance/playback differences, allows both the notation
 * and the sound to be represented. Artificial harmonics can
 * add a notated touching-pitch; the pitch or fret at which
 * the string is touched lightly to produce the harmonic.
 * Artificial pinch harmonics will usually not notate a
 * touching pitch. The attributes for the harmonic element
 * refer to the use of the circular harmonic symbol, typically
 * but not always used with natural harmonics.
 */
mixin template IHarmonic() {
    mixin IPrintObject;
    mixin IPrintStyle;
    mixin IPlacement;
    bool artificial;
    bool touchingPitch;
    bool soundingPitch;
    bool natural;
    bool basePitch;
}

/**
 * The open-string element represents the zero-shaped
 * open string symbol.
 */
export class OpenString {
    mixin IOpenString;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The open-string element represents the zero-shaped
 * open string symbol.
 */
mixin template IOpenString() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The thumb-position element represents the thumb position
 * symbol. This is a circle with a line, where the line does
 * not come within the circle. It is distinct from the snap
 * pizzicato symbol, where the line comes inside the circle.
 */
export class ThumbPosition {
    mixin IThumbPosition;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The thumb-position element represents the thumb position
 * symbol. This is a circle with a line, where the line does
 * not come within the circle. It is distinct from the snap
 * pizzicato symbol, where the line comes inside the circle.
 */
mixin template IThumbPosition() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The pluck element is used to specify the plucking fingering
 * on a fretted instrument, where the fingering element refers
 * to the fretting fingering. Typical values are p, i, m, a for
 * pulgar/thumb, indicio/index, medio/middle, and anular/ring
 * fingers.
 */
export class Pluck {
    mixin IPluck;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The pluck element is used to specify the plucking fingering
 * on a fretted instrument, where the fingering element refers
 * to the fretting fingering. Typical values are p, i, m, a for
 * pulgar/thumb, indicio/index, medio/middle, and anular/ring
 * fingers.
 */
mixin template IPluck() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * The double-tongue element represents the double tongue symbol
 * (two dots arranged horizontally).
 */
export class DoubleTongue {
    mixin IDoubleTongue;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The double-tongue element represents the double tongue symbol
 * (two dots arranged horizontally).
 */
mixin template IDoubleTongue() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The triple-tongue element represents the triple tongue symbol
 * (three dots arranged horizontally).
 */
export class TripleTongue {
    mixin ITripleTongue;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The triple-tongue element represents the triple tongue symbol
 * (three dots arranged horizontally).
 */
mixin template ITripleTongue() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The stopped element represents the stopped symbol, which looks
 * like a plus sign.
 */
export class Stopped {
    mixin IStopped;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The stopped element represents the stopped symbol, which looks
 * like a plus sign.
 */
mixin template IStopped() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The snap-pizzicato element represents the snap pizzicato
 * symbol. This is a circle with a line, where the line comes
 * inside the circle. It is distinct from the thumb-position
 * symbol, where the line does not come inside the circle.
 */
export class SnapPizzicato {
    mixin ISnapPizzicato;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The snap-pizzicato element represents the snap pizzicato
 * symbol. This is a circle with a line, where the line comes
 * inside the circle. It is distinct from the thumb-position
 * symbol, where the line does not come inside the circle.
 */
mixin template ISnapPizzicato() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The hammer-on and pull-off elements are used in guitar
 * and fretted instrument notation. Since a single slur
 * can be marked over many notes, the hammer-on and pull-off
 * elements are separate so the individual pair of notes can
 * be specified. The element content can be used to specify
 * how the hammer-on or pull-off should be notated. An empty
 * element leaves this choice up to the application.
 */
export class HammerOn {
    mixin IHammerOn;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The hammer-on and pull-off elements are used in guitar
 * and fretted instrument notation. Since a single slur
 * can be marked over many notes, the hammer-on and pull-off
 * elements are separate so the individual pair of notes can
 * be specified. The element content can be used to specify
 * how the hammer-on or pull-off should be notated. An empty
 * element leaves this choice up to the application.
 */
mixin template IHammerOn() {
    mixin IPrintStyle;
    mixin IPlacement;
    float number_;
    StartStop type;
    string data;
}

/**
 * The hammer-on and pull-off elements are used in guitar
 * and fretted instrument notation. Since a single slur
 * can be marked over many notes, the hammer-on and pull-off
 * elements are separate so the individual pair of notes can
 * be specified. The element content can be used to specify
 * how the hammer-on or pull-off should be notated. An empty
 * element leaves this choice up to the application.
 */
export class PullOff {
    mixin IPullOff;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The hammer-on and pull-off elements are used in guitar
 * and fretted instrument notation. Since a single slur
 * can be marked over many notes, the hammer-on and pull-off
 * elements are separate so the individual pair of notes can
 * be specified. The element content can be used to specify
 * how the hammer-on or pull-off should be notated. An empty
 * element leaves this choice up to the application.
 */
mixin template IPullOff() {
    mixin IPrintStyle;
    mixin IPlacement;
    float number_;
    StartStop type;
    string data;
}

/**
 * The bend element is used in guitar and tablature. The
 * bend-alter element indicates the number of steps in the
 * bend, similar to the alter element. As with the alter
 * element, numbers like 0.5 can be used to indicate
 * microtones. Negative numbers indicate pre-bends or
 * releases; the pre-bend and release elements are used
 * to distinguish what is intended. A with-bar element
 * indicates that the bend is to be done at the bridge
 * with a whammy or vibrato bar. The content of the
 * element indicates how this should be notated.
 */
export class Bend {
    mixin IBend;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundAccelerate = false;
        bool foundBeats = false;
        bool foundLastBeat = false;
        bool foundSecondBeat = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "bend-alter") {
                auto data = getString(ch, true);
                this.bendAlter = data;
            }
            if (ch.name.toString == "with-bar") {
                auto data = new WithBar(ch) ;
                this.withBar = data;
            }
            if (ch.name.toString == "pre-bend") {
                auto data = true;
                this.preBend = data;
            }
            if (ch.name.toString == "release") {
                auto data = true;
                this.release = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "accelerate") {
                auto data = getYesNo(ch, true);
                this.accelerate = data;
                foundAccelerate = true;
            }
            if (ch.name.toString == "beats") {
                auto data = getNumber(ch, true);
                this.beats = data;
                foundBeats = true;
            }
            if (ch.name.toString == "last-beat") {
                auto data = getNumber(ch, true);
                this.lastBeat = data;
                foundLastBeat = true;
            }
            if (ch.name.toString == "second-beat") {
                auto data = getNumber(ch, true);
                this.secondBeat = data;
                foundSecondBeat = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundAccelerate) {
            accelerate = false;
        }
        if (!foundBeats) {
            beats = 4;
        }
        if (!foundLastBeat) {
            lastBeat = 75;
        }
        if (!foundSecondBeat) {
            secondBeat = 25;
        }
    }
}

/**
 * The bend element is used in guitar and tablature. The
 * bend-alter element indicates the number of steps in the
 * bend, similar to the alter element. As with the alter
 * element, numbers like 0.5 can be used to indicate
 * microtones. Negative numbers indicate pre-bends or
 * releases; the pre-bend and release elements are used
 * to distinguish what is intended. A with-bar element
 * indicates that the bend is to be done at the bridge
 * with a whammy or vibrato bar. The content of the
 * element indicates how this should be notated.
 */
mixin template IBend() {
    mixin IPrintStyle;
    mixin IBendSound;
    string bendAlter;
    WithBar withBar;
    bool preBend;
    bool release;
}

/**
 * The bend element is used in guitar and tablature. The
 * bend-alter element indicates the number of steps in the
 * bend, similar to the alter element. As with the alter
 * element, numbers like 0.5 can be used to indicate
 * microtones. Negative numbers indicate pre-bends or
 * releases; the pre-bend and release elements are used
 * to distinguish what is intended. A with-bar element
 * indicates that the bend is to be done at the bridge
 * with a whammy or vibrato bar. The content of the
 * element indicates how this should be notated.
 */
export class WithBar {
    mixin IWithBar;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The bend element is used in guitar and tablature. The
 * bend-alter element indicates the number of steps in the
 * bend, similar to the alter element. As with the alter
 * element, numbers like 0.5 can be used to indicate
 * microtones. Negative numbers indicate pre-bends or
 * releases; the pre-bend and release elements are used
 * to distinguish what is intended. A with-bar element
 * indicates that the bend is to be done at the bridge
 * with a whammy or vibrato bar. The content of the
 * element indicates how this should be notated.
 */
mixin template IWithBar() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * The tap element indicates a tap on the fretboard. The
 * element content allows specification of the notation;
 * + and T are common choices. If empty, the display is
 * application-specific.
 */
export class Tap {
    mixin ITap;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The tap element indicates a tap on the fretboard. The
 * element content allows specification of the notation;
 * + and T are common choices. If empty, the display is
 * application-specific.
 */
mixin template ITap() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * The heel and toe element are used with organ pedals. The
 * substitution value is "no" if the attribute is not present.
 */
export class Heel {
    mixin IHeel;
    this(xmlNodePtr node) {
        bool foundSubstitution = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "substitution") {
                auto data = getYesNo(ch, true);
                this.substitution = data;
                foundSubstitution = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundSubstitution) {
            substitution = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The heel and toe element are used with organ pedals. The
 * substitution value is "no" if the attribute is not present.
 */
mixin template IHeel() {
    mixin IPrintStyle;
    mixin IPlacement;
    bool substitution;
}

/**
 * The heel and toe element are used with organ pedals. The
 * substitution value is "no" if the attribute is not present.
 */
export class Toe {
    mixin IToe;
    this(xmlNodePtr node) {
        bool foundSubstitution = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "substitution") {
                auto data = getYesNo(ch, true);
                this.substitution = data;
                foundSubstitution = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundSubstitution) {
            substitution = false;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The heel and toe element are used with organ pedals. The
 * substitution value is "no" if the attribute is not present.
 */
mixin template IToe() {
    mixin IPrintStyle;
    mixin IPlacement;
    bool substitution;
}

/**
 * The fingernails element is used in notation for harp and
 * other plucked string instruments.
 */
export class Fingernails {
    mixin IFingernails;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The fingernails element is used in notation for harp and
 * other plucked string instruments.
 */
mixin template IFingernails() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */
export class Hole {
    mixin IHole;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "hole-closed") {
                auto data = new HoleClosed(ch) ;
                this.holeClosed = data;
            }
            if (ch.name.toString == "hole-shape") {
                auto data = getString(ch, true);
                this.holeShape = data;
            }
            if (ch.name.toString == "hole-type") {
                auto data = getString(ch, true);
                this.holeType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */
mixin template IHole() {
    mixin IPrintStyle;
    mixin IPlacement;
    HoleClosed holeClosed;
    string holeShape;
    string holeType;
}

export enum HoleLocation {
    Right = 0,
    Top = 3,
    Bottom = 1,
    Left = 2
}

HoleLocation getHoleLocation(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return HoleLocation.Right;
    }
    if (s == "top") {
        return HoleLocation.Top;
    }
    if (s == "bottom") {
        return HoleLocation.Bottom;
    }
    if (s == "left") {
        return HoleLocation.Left;
    }
    assert(false, "Not reached");
}
export enum HoleClosedType {
    No = 1,
    Yes = 0,
    Half = 2
}

HoleClosedType getHoleClosedType(T)(T p) {
    string s = getString(p, true);
    if (s == "no") {
        return HoleClosedType.No;
    }
    if (s == "yes") {
        return HoleClosedType.Yes;
    }
    if (s == "half") {
        return HoleClosedType.Half;
    }
    assert(false, "Not reached");
}
/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */
export class HoleClosed {
    mixin IHoleClosed;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "location") {
                auto data = getHoleLocation(ch);
                this.location = data;
            }
        }
        auto ch = node;
        auto data = getHoleClosedType(ch);
        this.data = data;
    }
}

/**
 * The hole element represents the symbols used for woodwind
 * and brass fingerings as well as other notations. The content
 * of the optional hole-type element indicates what the hole
 * symbol represents in terms of instrument fingering or other
 * techniques. The hole-closed element represents whether the
 * hole is closed, open, or half-open. Valid element values are
 * yes, no, and half. The optional location attribute indicates
 * which portion of the hole is filled in when the element value
 * is half. The optional hole-shape element indicates the shape
 * of the hole symbol; the default is a circle.
 */
mixin template IHoleClosed() {
    HoleLocation location;
    HoleClosedType data;
}

/**
 * The arrow element represents an arrow used for a musical
 * technical indication. Straight arrows are represented with
 * an arrow-direction element and an optional arrow-style
 * element. Circular arrows are represented with a
 * circular-arrow element. Descriptive values use Unicode
 * arrow terminology.
 * 
 * Values for the arrow-direction element are left, up, right,
 * down, northwest, northeast, southeast, southwest, left right,
 * up down, northwest southeast, northeast southwest, and other.
 * 
 * Values for the arrow-style element are single, double,
 * filled, hollow, paired, combined, and other. Filled and
 * hollow arrows indicate polygonal single arrows. Paired
 * arrows are duplicate single arrows in the same direction.
 * Combined arrows apply to double direction arrows like
 * left right, indicating that an arrow in one direction
 * should be combined with an arrow in the other direction.
 * 
 * Values for the circular-arrow element are clockwise and
 * anticlockwise.
 */
export class Arrow {
    mixin IArrow;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "arrow-style") {
                auto data = getString(ch, true);
                this.arrowStyle = data;
            }
            if (ch.name.toString == "arrow-direction") {
                auto data = getString(ch, true);
                this.arrowDirection = data;
            }
            if (ch.name.toString == "circular-arrow") {
                auto data = getString(ch, true);
                this.circularArrow = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The arrow element represents an arrow used for a musical
 * technical indication. Straight arrows are represented with
 * an arrow-direction element and an optional arrow-style
 * element. Circular arrows are represented with a
 * circular-arrow element. Descriptive values use Unicode
 * arrow terminology.
 * 
 * Values for the arrow-direction element are left, up, right,
 * down, northwest, northeast, southeast, southwest, left right,
 * up down, northwest southeast, northeast southwest, and other.
 * 
 * Values for the arrow-style element are single, double,
 * filled, hollow, paired, combined, and other. Filled and
 * hollow arrows indicate polygonal single arrows. Paired
 * arrows are duplicate single arrows in the same direction.
 * Combined arrows apply to double direction arrows like
 * left right, indicating that an arrow in one direction
 * should be combined with an arrow in the other direction.
 * 
 * Values for the circular-arrow element are clockwise and
 * anticlockwise.
 */
mixin template IArrow() {
    mixin IPrintStyle;
    mixin IPlacement;
    string arrowStyle;
    string arrowDirection;
    string circularArrow;
}

/**
 * The handbell element represents notation for various
 * techniques used in handbell and handchime music. Valid
 * values are damp, echo, gyro, hand martellato, mallet lift,
 * mallet table, martellato, martellato lift,
 * muted martellato, pluck lift, and swing.
 */
export class Handbell {
    mixin IHandbell;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The handbell element represents notation for various
 * techniques used in handbell and handchime music. Valid
 * values are damp, echo, gyro, hand martellato, mallet lift,
 * mallet table, martellato, martellato lift,
 * muted martellato, pluck lift, and swing.
 */
mixin template IHandbell() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * The other-technical element is used to define any technical
 * indications not yet in the MusicXML format. This allows
 * extended representation, though without application
 * interoperability.
 */
export class OtherTechnical {
    mixin IOtherTechnical;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The other-technical element is used to define any technical
 * indications not yet in the MusicXML format. This allows
 * extended representation, though without application
 * interoperability.
 */
mixin template IOtherTechnical() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * Articulations and accents are grouped together here.
 */
export class Articulations {
    mixin IArticulations;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "accent") {
                auto data = new Accent(ch) ;
                this.accent = data;
            }
            if (ch.name.toString == "doit") {
                auto data = new Doit(ch) ;
                this.doit = data;
            }
            if (ch.name.toString == "breath-mark") {
                auto data = new BreathMark(ch) ;
                this.breathMark = data;
            }
            if (ch.name.toString == "other-articulation") {
                auto data = new OtherArticulation(ch) ;
                this.otherArticulations ~= data;
            }
            if (ch.name.toString == "detached-legato") {
                auto data = new DetachedLegato(ch) ;
                this.detachedLegato = data;
            }
            if (ch.name.toString == "staccatissimo") {
                auto data = new Staccatissimo(ch) ;
                this.staccatissimo = data;
            }
            if (ch.name.toString == "plop") {
                auto data = new Plop(ch) ;
                this.plop = data;
            }
            if (ch.name.toString == "unstress") {
                auto data = new Unstress(ch) ;
                this.unstress = data;
            }
            if (ch.name.toString == "strong-accent") {
                auto data = new StrongAccent(ch) ;
                this.strongAccent = data;
            }
            if (ch.name.toString == "staccato") {
                auto data = new Staccato(ch) ;
                this.staccato = data;
            }
            if (ch.name.toString == "spiccato") {
                auto data = new Spiccato(ch) ;
                this.spiccato = data;
            }
            if (ch.name.toString == "scoop") {
                auto data = new Scoop(ch) ;
                this.scoop = data;
            }
            if (ch.name.toString == "falloff") {
                auto data = new Falloff(ch) ;
                this.falloff = data;
            }
            if (ch.name.toString == "caesura") {
                auto data = new Caesura(ch) ;
                this.caesura = data;
            }
            if (ch.name.toString == "stress") {
                auto data = new Stress(ch) ;
                this.stress = data;
            }
            if (ch.name.toString == "tenuto") {
                auto data = new Tenuto(ch) ;
                this.tenuto = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Articulations and accents are grouped together here.
 */
mixin template IArticulations() {
    Accent accent;
    Doit doit;
    BreathMark breathMark;
    OtherArticulation[] otherArticulations;
    DetachedLegato detachedLegato;
    Staccatissimo staccatissimo;
    Plop plop;
    Unstress unstress;
    StrongAccent strongAccent;
    Staccato staccato;
    Spiccato spiccato;
    Scoop scoop;
    Falloff falloff;
    Caesura caesura;
    Stress stress;
    Tenuto tenuto;
}

export class Accent {
    mixin IAccent;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template IAccent() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export class StrongAccent {
    mixin IStrongAccent;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        bool foundType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getUpDown(ch);
                this.type = data;
                foundType = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundType) {
            type = UpDown.Up;
        }
    }
}

mixin template IStrongAccent() {
    mixin IPrintStyle;
    mixin IPlacement;
    UpDown type;
}

/**
 * The staccato element is used for a dot articulation, as
 * opposed to a stroke or a wedge.
 */
export class Staccato {
    mixin IStaccato;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The staccato element is used for a dot articulation, as
 * opposed to a stroke or a wedge.
 */
mixin template IStaccato() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export class Tenuto {
    mixin ITenuto;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template ITenuto() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export class DetachedLegato {
    mixin IDetachedLegato;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template IDetachedLegato() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The staccatissimo element is used for a wedge articulation,
 * as opposed to a dot or a stroke.
 */
export class Staccatissimo {
    mixin IStaccatissimo;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The staccatissimo element is used for a wedge articulation,
 * as opposed to a dot or a stroke.
 */
mixin template IStaccatissimo() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The spiccato element is used for a stroke articulation, as
 * opposed to a dot or a wedge.
 */
export class Spiccato {
    mixin ISpiccato;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The spiccato element is used for a stroke articulation, as
 * opposed to a dot or a wedge.
 */
mixin template ISpiccato() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
export class Scoop {
    mixin IScoop;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
mixin template IScoop() {
    mixin ILineShape;
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
export class Plop {
    mixin IPlop;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
mixin template IPlop() {
    mixin ILineShape;
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
export class Doit {
    mixin IDoit;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
mixin template IDoit() {
    mixin ILineShape;
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
export class Falloff {
    mixin IFalloff;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The scoop, plop, doit, and falloff elements are
 * indeterminate slides attached to a single note.
 * Scoops and plops come before the main note, coming
 * from below and above the pitch, respectively. Doits
 * and falloffs come after the main note, going above
 * and below the pitch, respectively.
 */
mixin template IFalloff() {
    mixin ILineShape;
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IPlacement;
}

export enum BreathMarkType {
    Empty = 2,
    Comma = 0,
    Tick = 1
}

BreathMarkType getBreathMarkType(T)(T p) {
    string s = getString(p, true);
    if (s == "") {
        return BreathMarkType.Empty;
    }
    if (s == "comma") {
        return BreathMarkType.Comma;
    }
    if (s == "tick") {
        return BreathMarkType.Tick;
    }
    assert(false, "Not reached");
}
/**
 * The breath-mark element may have a text value to
 * indicate the symbol used for the mark. Valid values are
 * comma, tick, and an empty string.
 */
export class BreathMark {
    mixin IBreathMark;
    this(xmlNodePtr node) {
        bool foundLineShape = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line-shape") {
                auto data = getStraightCurved(ch);
                this.lineShape = data;
                foundLineShape = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getBreathMarkType(ch);
        this.type = data;
        if (!foundLineShape) {
            lineShape = StraightCurved.Straight;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The breath-mark element may have a text value to
 * indicate the symbol used for the mark. Valid values are
 * comma, tick, and an empty string.
 */
mixin template IBreathMark() {
    mixin ILineShape;
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPrintStyle;
    mixin IPlacement;
    BreathMarkType type;
}

export class Caesura {
    mixin ICaesura;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template ICaesura() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export class Stress {
    mixin IStress;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template IStress() {
    mixin IPrintStyle;
    mixin IPlacement;
}

export class Unstress {
    mixin IUnstress;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template IUnstress() {
    mixin IPrintStyle;
    mixin IPlacement;
}

/**
 * The other-articulation element is used to define any
 * articulations not yet in the MusicXML format. This allows
 * extended representation, though without application
 * interoperability.
 */
export class OtherArticulation {
    mixin IOtherArticulation;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

/**
 * The other-articulation element is used to define any
 * articulations not yet in the MusicXML format. This allows
 * extended representation, though without application
 * interoperability.
 */
mixin template IOtherArticulation() {
    mixin IPrintStyle;
    mixin IPlacement;
    string data;
}

/**
 * The arpeggiate element indicates that this note is part of
 * an arpeggiated chord. The number attribute can be used to
 * distinguish between two simultaneous chords arpeggiated
 * separately (different numbers) or together (same number).
 * The up-down attribute is used if there is an arrow on the
 * arpeggio sign. By default, arpeggios go from the lowest to
 * highest note.
 */
export class Arpeggiate {
    mixin IArpeggiate;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundPlacement = false;
        bool foundColor = false;
        bool foundDirection = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "direction") {
                auto data = getUpDown(ch);
                this.direction = data;
                foundDirection = true;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundDirection) {
            direction = UpDown.Up;
        }
    }
}

/**
 * The arpeggiate element indicates that this note is part of
 * an arpeggiated chord. The number attribute can be used to
 * distinguish between two simultaneous chords arpeggiated
 * separately (different numbers) or together (same number).
 * The up-down attribute is used if there is an arrow on the
 * arpeggio sign. By default, arpeggios go from the lowest to
 * highest note.
 */
mixin template IArpeggiate() {
    mixin IPosition;
    mixin IPlacement;
    mixin IColor;
    float number_;
    UpDown direction;
}

/**
 * The non-arpeggiate element indicates that this note is at
 * the top or bottom of a bracket indicating to not arpeggiate
 * these notes. Since this does not involve playback, it is
 * only used on the top or bottom notes, not on each note
 * as for the arpeggiate element.
 */
export class NonArpeggiate {
    mixin INonArpeggiate;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundPlacement = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getTopBottom(ch);
                this.type = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The non-arpeggiate element indicates that this note is at
 * the top or bottom of a bracket indicating to not arpeggiate
 * these notes. Since this does not involve playback, it is
 * only used on the top or bottom notes, not on each note
 * as for the arpeggiate element.
 */
mixin template INonArpeggiate() {
    mixin IPosition;
    mixin IPlacement;
    mixin IColor;
    float number_;
    TopBottom type;
}

/**
 * Humming and laughing representations are taken from
 * Humdrum.
 */
export class Laughing {
    mixin ILaughing;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Humming and laughing representations are taken from
 * Humdrum.
 */
mixin template ILaughing() {
}

/**
 * Humming and laughing representations are taken from
 * Humdrum.
 */
export class Humming {
    mixin IHumming;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Humming and laughing representations are taken from
 * Humdrum.
 */
mixin template IHumming() {
}

/**
 * The end-line and end-paragraph elements come
 * from RP-017 for Standard MIDI File Lyric meta-events;
 * they help facilitate lyric display for Karaoke and
 * similar applications.
 */
export class EndLine {
    mixin IEndLine;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The end-line and end-paragraph elements come
 * from RP-017 for Standard MIDI File Lyric meta-events;
 * they help facilitate lyric display for Karaoke and
 * similar applications.
 */
mixin template IEndLine() {
}

/**
 * The end-line and end-paragraph elements come
 * from RP-017 for Standard MIDI File Lyric meta-events;
 * they help facilitate lyric display for Karaoke and
 * similar applications.
 */
export class EndParagraph {
    mixin IEndParagraph;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The end-line and end-paragraph elements come
 * from RP-017 for Standard MIDI File Lyric meta-events;
 * they help facilitate lyric display for Karaoke and
 * similar applications.
 */
mixin template IEndParagraph() {
}

/**
 * Fake element containing ordered content. Children of lyric-parts are actually children of lyric. See lyric.
 */
Variant[] LyricParts(xmlNodePtr node) {
    Variant[] rarr = [];
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "extend") {
                auto data = Variant(new Extend(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "end-line") {
                auto data = Variant(new EndLine(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "syllabic") {
                auto data = Variant(new Syllabic(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "text") {
                auto data = Variant(new Text(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "laughing") {
                auto data = Variant(new Laughing(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "humming") {
                auto data = Variant(new Humming(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "end-paragraph") {
                auto data = Variant(new EndParagraph(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "elision") {
                auto data = Variant(new Elision(ch) );
                rarr ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    return rarr;
}


/**
 * Text underlays for lyrics, based on Humdrum with support
 * for other formats.
 * 
 * IMPORTANT: <lyric-parts> is fake. All children of lyric-parts
 * are actually children of lyric. This is a construct invented by
 * musicxml-interfaces for separating ordered and unordered
 * content.
 * 
 * Language names for text elements come from ISO 639,
 * with optional country subcodes from ISO 3166. muiscxml-interfaces
 * currently ignores this field. 
 * 
 * Justification is center by default; placement is
 * below by default. The print-object attribute can override
 * a note's print-lyric attribute in cases where only some
 * lyrics on a note are printed, as when lyrics for later verses
 * are printed in a block of text rather than with each note.
 * 
 */
mixin template ILyric() {
    mixin IJustify;
    mixin IPosition;
    mixin IPlacement;
    mixin IColor;
    mixin IPrintObject;
    mixin IEditorial;
    Variant[] lyricParts;
    float number_;
    string name;
}

export class Text {
    mixin IText;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundDir = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
    }
}

mixin template IText() {
    mixin IFont;
    mixin IColor;
    mixin ITextDecoration;
    mixin ITextRotation;
    mixin ILetterSpacing;
    mixin ITextDirection;
    string data;
}

export enum SyllabicType {
    Single = 0,
    Begin = 1,
    Middle = 3,
    End = 2
}

SyllabicType getSyllabicType(T)(T p) {
    string s = getString(p, true);
    if (s == "single") {
        return SyllabicType.Single;
    }
    if (s == "begin") {
        return SyllabicType.Begin;
    }
    if (s == "middle") {
        return SyllabicType.Middle;
    }
    if (s == "end") {
        return SyllabicType.End;
    }
    assert(false, "Not reached");
}
/**
 * Hyphenation is indicated by the syllabic element, which can be single,
 * begin, end, or middle. These represent single-syllable
 * words, word-beginning syllables, word-ending syllables,
 * and mid-word syllables.
 */
export class Syllabic {
    mixin ISyllabic;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getSyllabicType(ch);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Hyphenation is indicated by the syllabic element, which can be single,
 * begin, end, or middle. These represent single-syllable
 * words, word-beginning syllables, word-ending syllables,
 * and mid-word syllables.
 */
mixin template ISyllabic() {
    mixin IFont;
    mixin IColor;
    SyllabicType data;
}

/**
 * Multiple syllables on a single note are separated by elision
 * elements. A hyphen in the text element should only be used
 * for an actual hyphenated word. Two text elements that are
 * not separated by an elision element are part of the same
 * syllable, but may have different text formatting.
 * 
 * The elision element text specifies the symbol used to
 * display the elision. Common values are a no-break space
 * (Unicode 00A0), an underscore (Unicode 005F), or an undertie
 * (Unicode 203F).
 */
export class Elision {
    mixin IElision;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Multiple syllables on a single note are separated by elision
 * elements. A hyphen in the text element should only be used
 * for an actual hyphenated word. Two text elements that are
 * not separated by an elision element are part of the same
 * syllable, but may have different text formatting.
 * 
 * The elision element text specifies the symbol used to
 * display the elision. Common values are a no-break space
 * (Unicode 00A0), an underscore (Unicode 005F), or an undertie
 * (Unicode 203F).
 */
mixin template IElision() {
    mixin IFont;
    mixin IColor;
    string data;
}

/**
 * Word extensions are represented using the extend element. 
 * 
 * The extend element represents lyric word extension /
 * melisma lines as well as figured bass extensions. The
 * optional type and position attributes are added in
 * Version 3.0 to provide better formatting control.
 */
export class Extend {
    mixin IExtend;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundType = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
                foundType = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundType) {
            type = StartStopContinue.Start;
        }
    }
}

/**
 * Word extensions are represented using the extend element. 
 * 
 * The extend element represents lyric word extension /
 * melisma lines as well as figured bass extensions. The
 * optional type and position attributes are added in
 * Version 3.0 to provide better formatting control.
 */
mixin template IExtend() {
    mixin IPrintStyle;
    StartStopContinue type;
}

/**
 * Figured bass elements take their position from the first
 * regular note (not a grace note or chord note) that follows
 * in score order. The optional duration element is used to
 * indicate changes of figures under a note.    
 * 
 * Figures are ordered from top to bottom. A figure-number is a
 * number. Values for prefix and suffix include the accidental
 * values sharp, flat, natural, double-sharp, flat-flat, and
 * sharp-sharp. Suffixes include both symbols that come after
 * the figure number and those that overstrike the figure number.
 * The suffix value slash is used for slashed numbers indicating
 * chromatic alteration. The orientation and display of the slash
 * usually depends on the figure number. The prefix and suffix
 * elements may contain additional values for symbols specific
 * to particular figured bass styles. The value of parentheses
 * is "no" if not present.
 */
export class FiguredBass {
    mixin IFiguredBass;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        bool foundPrintSpacing = false;
        bool foundParentheses = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "figure") {
                auto data = new Figure(ch) ;
                this.figures ~= data;
            }
            if (ch.name.toString == "duration") {
                auto data = getNumber(ch, true);
                this.duration = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-dot") {
                auto data = getYesNo(ch, true);
                this.printDot = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "print-spacing") {
                auto data = getYesNo(ch, true);
                this.printSpacing = data;
                foundPrintSpacing = true;
            }
            if (ch.name.toString == "print-lyric") {
                auto data = getYesNo(ch, true);
                this.printLyric = data;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
                foundParentheses = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundPrintSpacing) {
            printSpacing = true;
        }
        if (!foundParentheses) {
            parentheses = false;
        }
    }
}

/**
 * Figured bass elements take their position from the first
 * regular note (not a grace note or chord note) that follows
 * in score order. The optional duration element is used to
 * indicate changes of figures under a note.    
 * 
 * Figures are ordered from top to bottom. A figure-number is a
 * number. Values for prefix and suffix include the accidental
 * values sharp, flat, natural, double-sharp, flat-flat, and
 * sharp-sharp. Suffixes include both symbols that come after
 * the figure number and those that overstrike the figure number.
 * The suffix value slash is used for slashed numbers indicating
 * chromatic alteration. The orientation and display of the slash
 * usually depends on the figure number. The prefix and suffix
 * elements may contain additional values for symbols specific
 * to particular figured bass styles. The value of parentheses
 * is "no" if not present.
 */
mixin template IFiguredBass() {
    mixin IEditorial;
    mixin IPrintStyle;
    mixin IPrintout;
    Figure[] figures;
    float duration;
    bool parentheses;
}

export class Figure {
    mixin IFigure;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "prefix") {
                auto data = new Prefix(ch) ;
                this.prefix = data;
            }
            if (ch.name.toString == "figure-number") {
                auto data = new FigureNumber(ch) ;
                this.figureNumber = data;
            }
            if (ch.name.toString == "extend") {
                auto data = new Extend(ch) ;
                this.extend = data;
            }
            if (ch.name.toString == "suffix") {
                auto data = new Suffix(ch) ;
                this.suffix = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IFigure() {
    mixin IPrintStyle;
    Prefix prefix;
    FigureNumber figureNumber;
    Extend extend;
    Suffix suffix;
}

export class Prefix {
    mixin IPrefix;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IPrefix() {
    mixin IPrintStyle;
    string data;
}

export class FigureNumber {
    mixin IFigureNumber;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IFigureNumber() {
    mixin IPrintStyle;
    string data;
}

export class Suffix {
    mixin ISuffix;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template ISuffix() {
    mixin IPrintStyle;
    string data;
}

/**
 * The backup and forward elements are required to coordinate
 * multiple voices in one part, including music on multiple
 * staves.
 * 
 * The backup element is generally used to
 * move between voices and staves. Thus the backup element
 * does not include voice or staff elements. Duration values
 * should always be positive, and should not cross measure
 * boundaries or mid-measure changes in the divisions value.
 */
export class Backup {
    mixin IBackup;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "duration") {
                auto data = getNumber(ch, true);
                this.duration = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The backup and forward elements are required to coordinate
 * multiple voices in one part, including music on multiple
 * staves.
 * 
 * The backup element is generally used to
 * move between voices and staves. Thus the backup element
 * does not include voice or staff elements. Duration values
 * should always be positive, and should not cross measure
 * boundaries or mid-measure changes in the divisions value.
 */
mixin template IBackup() {
    mixin IEditorial;
    float duration;
}

/**
 * The backup and forward elements are required to coordinate
 * multiple voices in one part, including music on multiple
 * staves.
 * 
 * The forward element is generally used within voices
 * and staves. Duration values should always be positive, and
 * should not cross measure boundaries or mid-measure changes
 * in the divisions value.
 */
export class Forward {
    mixin IForward;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "voice") {
                auto data = getNumber(ch, true);
                this.voice = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "duration") {
                auto data = getNumber(ch, true);
                this.duration = data;
            }
            if (ch.name.toString == "staff") {
                auto data = getNumber(ch, true);
                this.staff = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The backup and forward elements are required to coordinate
 * multiple voices in one part, including music on multiple
 * staves.
 * 
 * The forward element is generally used within voices
 * and staves. Duration values should always be positive, and
 * should not cross measure boundaries or mid-measure changes
 * in the divisions value.
 */
mixin template IForward() {
    mixin IEditorialVoice;
    float duration;
    float staff;
}

export enum BarlineLocation {
    Right = 1,
    Middle = 2,
    Left = 0
}

BarlineLocation getBarlineLocation(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return BarlineLocation.Right;
    }
    if (s == "middle") {
        return BarlineLocation.Middle;
    }
    if (s == "left") {
        return BarlineLocation.Left;
    }
    assert(false, "Not reached");
}
/**
 * If a barline is other than a normal single barline, it
 * should be represented by a barline element that describes
 * it. This includes information about repeats and multiple
 * endings, as well as line style. Barline data is on the same
 * level as the other musical data in a score - a child of a
 * measure in a partwise score, or a part in a timewise score.
 * This allows for barlines within measures, as in dotted
 * barlines that subdivide measures in complex meters. The two
 * fermata elements allow for fermatas on both sides of the
 * barline (the lower one inverted).
 * 
 * Barlines have a location attribute to make it easier to
 * process barlines independently of the other musical data
 * in a score. It is often easier to set up measures
 * separately from entering notes. The location attribute
 * must match where the barline element occurs within the
 * rest of the musical data in the score. If location is left,
 * it should be the first element in the measure, aside from
 * the print, bookmark, and link elements. If location is
 * right, it should be the last element, again with the
 * possible exception of the print, bookmark, and link
 * elements. If no location is specified, the right barline
 * is the default. The segno, coda, and divisions attributes
 * work the same way as in the sound element defined in the
 * direction.mod file. They are used for playback when barline
 * elements contain segno or coda child elements.
 */
export class Barline {
    mixin IBarline;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "segno") {
                auto data = new Segno(ch) ;
                this.segno = data;
            }
            if (ch.name.toString == "coda") {
                auto data = new Coda(ch) ;
                this.coda = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "wavy-line") {
                auto data = new WavyLine(ch) ;
                this.wavyLine = data;
            }
            if (ch.name.toString == "fermata") {
                auto data = new Fermata(ch) ;
                this.fermatas ~= data;
            }
            if (ch.name.toString == "bar-style") {
                auto data = new BarStyle(ch) ;
                this.barStyle = data;
            }
            if (ch.name.toString == "ending") {
                auto data = new Ending(ch) ;
                this.ending = data;
            }
            if (ch.name.toString == "repeat") {
                auto data = new Repeat(ch) ;
                this.repeat = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "location") {
                auto data = getBarlineLocation(ch);
                this.location = data;
            }
            if (ch.name.toString == "coda") {
                auto data = getString(ch, true);
                this.codaAttrib = data;
            }
            if (ch.name.toString == "segno") {
                auto data = getString(ch, true);
                this.segnoAttrib = data;
            }
            if (ch.name.toString == "divisions") {
                auto data = getString(ch, true);
                this.divisions = data;
            }
        }
    }
}

/**
 * If a barline is other than a normal single barline, it
 * should be represented by a barline element that describes
 * it. This includes information about repeats and multiple
 * endings, as well as line style. Barline data is on the same
 * level as the other musical data in a score - a child of a
 * measure in a partwise score, or a part in a timewise score.
 * This allows for barlines within measures, as in dotted
 * barlines that subdivide measures in complex meters. The two
 * fermata elements allow for fermatas on both sides of the
 * barline (the lower one inverted).
 * 
 * Barlines have a location attribute to make it easier to
 * process barlines independently of the other musical data
 * in a score. It is often easier to set up measures
 * separately from entering notes. The location attribute
 * must match where the barline element occurs within the
 * rest of the musical data in the score. If location is left,
 * it should be the first element in the measure, aside from
 * the print, bookmark, and link elements. If location is
 * right, it should be the last element, again with the
 * possible exception of the print, bookmark, and link
 * elements. If no location is specified, the right barline
 * is the default. The segno, coda, and divisions attributes
 * work the same way as in the sound element defined in the
 * direction.mod file. They are used for playback when barline
 * elements contain segno or coda child elements.
 */
mixin template IBarline() {
    mixin IEditorial;
    Segno segno;
    Coda coda;
    BarlineLocation location;
    string codaAttrib;
    WavyLine wavyLine;
    Fermata[] fermatas;
    string segnoAttrib;
    string divisions;
    BarStyle barStyle;
    Ending ending;
    Repeat repeat;
}

/**
 * Bar-style contains style information. Choices are
 * regular, dotted, dashed, heavy, light-light,
 * light-heavy, heavy-light, heavy-heavy, tick (a
 * short stroke through the top line), short (a partial
 * barline between the 2nd and 4th lines), and none.
 */
export enum BarStyleType {
    Regular = 0,
    LightHeavy = 5,
    HeavyLight = 6,
    Short = 9,
    None = 10,
    Dashed = 2,
    HeavyHeavy = 7,
    Tick = 8,
    Dotted = 1,
    Heavy = 3,
    LightLight = 4
}

BarStyleType getBarStyleType(T)(T p) {
    string s = getString(p, true);
    if (s == "regular") {
        return BarStyleType.Regular;
    }
    if (s == "light-heavy") {
        return BarStyleType.LightHeavy;
    }
    if (s == "heavy-light") {
        return BarStyleType.HeavyLight;
    }
    if (s == "short") {
        return BarStyleType.Short;
    }
    if (s == "none") {
        return BarStyleType.None;
    }
    if (s == "dashed") {
        return BarStyleType.Dashed;
    }
    if (s == "heavy-heavy") {
        return BarStyleType.HeavyHeavy;
    }
    if (s == "tick") {
        return BarStyleType.Tick;
    }
    if (s == "dotted") {
        return BarStyleType.Dotted;
    }
    if (s == "heavy") {
        return BarStyleType.Heavy;
    }
    if (s == "light-light") {
        return BarStyleType.LightLight;
    }
    assert(false, "Not reached");
}
/**
 * Bar-style contains style information. Choices are
 * regular, dotted, dashed, heavy, light-light,
 * light-heavy, heavy-light, heavy-heavy, tick (a
 * short stroke through the top line), short (a partial
 * barline between the 2nd and 4th lines), and none.
 */
export class BarStyle {
    mixin IBarStyle;
    this(xmlNodePtr node) {
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getBarStyleType(ch);
        this.data = data;
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Bar-style contains style information. Choices are
 * regular, dotted, dashed, heavy, light-light,
 * light-heavy, heavy-light, heavy-heavy, tick (a
 * short stroke through the top line), short (a partial
 * barline between the 2nd and 4th lines), and none.
 */
mixin template IBarStyle() {
    mixin IColor;
    BarStyleType data;
}

export enum StartStopDiscontinue {
    Discontinue = 2,
    Start = 0,
    Stop = 1
}

StartStopDiscontinue getStartStopDiscontinue(T)(T p) {
    string s = getString(p, true);
    if (s == "discontinue") {
        return StartStopDiscontinue.Discontinue;
    }
    if (s == "start") {
        return StartStopDiscontinue.Start;
    }
    if (s == "stop") {
        return StartStopDiscontinue.Stop;
    }
    assert(false, "Not reached");
}
/**
 * Endings refers to multiple (e.g. first and second) endings.
 * Typically, the start type is associated with the left
 * barline of the first measure in an ending. The stop and
 * discontinue types are associated with the right barline of
 * the last measure in an ending. Stop is used when the ending
 * mark concludes with a downward jog, as is typical for first
 * endings. Discontinue is used when there is no downward jog,
 * as is typical for second endings that do not conclude a
 * piece. The length of the jog can be specified using the
 * end-length attribute. The text-x and text-y attributes
 * are offsets that specify where the baseline of the start
 * of the ending text appears, relative to the start of the
 * ending line.
 * 
 * The number attribute reflects the numeric values of what
 * is under the ending line. Single endings such as "1" or
 * comma-separated multiple endings such as "1, 2" may be
 * used. The ending element text is used when the text
 * displayed in the ending is different than what appears in
 * the number attribute. The print-object element is used to
 * indicate when an ending is present but not printed, as is
 * often the case for many parts in a full score.
 */
export class Ending {
    mixin IEnding;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "end-length") {
                auto data = getNumber(ch, true);
                this.endLength = data;
            }
            if (ch.name.toString == "text-x") {
                auto data = getNumber(ch, true);
                this.textX = data;
            }
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "text-y") {
                auto data = getNumber(ch, true);
                this.textY = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopDiscontinue(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.ending = data;
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Endings refers to multiple (e.g. first and second) endings.
 * Typically, the start type is associated with the left
 * barline of the first measure in an ending. The stop and
 * discontinue types are associated with the right barline of
 * the last measure in an ending. Stop is used when the ending
 * mark concludes with a downward jog, as is typical for first
 * endings. Discontinue is used when there is no downward jog,
 * as is typical for second endings that do not conclude a
 * piece. The length of the jog can be specified using the
 * end-length attribute. The text-x and text-y attributes
 * are offsets that specify where the baseline of the start
 * of the ending text appears, relative to the start of the
 * ending line.
 * 
 * The number attribute reflects the numeric values of what
 * is under the ending line. Single endings such as "1" or
 * comma-separated multiple endings such as "1, 2" may be
 * used. The ending element text is used when the text
 * displayed in the ending is different than what appears in
 * the number attribute. The print-object element is used to
 * indicate when an ending is present but not printed, as is
 * often the case for many parts in a full score.
 */
mixin template IEnding() {
    mixin IPrintObject;
    mixin IPrintStyle;
    float endLength;
    float textX;
    float number_;
    float textY;
    StartStopDiscontinue type;
    string ending;
}

export enum WingedType {
    None = 0,
    Curved = 2,
    DoubleCurved = 4,
    Straight = 1,
    DoubleStraight = 3
}

WingedType getWingedType(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return WingedType.None;
    }
    if (s == "curved") {
        return WingedType.Curved;
    }
    if (s == "double-curved") {
        return WingedType.DoubleCurved;
    }
    if (s == "straight") {
        return WingedType.Straight;
    }
    if (s == "double-straight") {
        return WingedType.DoubleStraight;
    }
    assert(false, "Not reached");
}
export enum DirectionTypeBg {
    Forward = 1,
    Backward = 0
}

DirectionTypeBg getDirectionTypeBg(T)(T p) {
    string s = getString(p, true);
    if (s == "forward") {
        return DirectionTypeBg.Forward;
    }
    if (s == "backward") {
        return DirectionTypeBg.Backward;
    }
    assert(false, "Not reached");
}
/**
 * Repeat marks. The start of the repeat has a forward direction
 * while the end of the repeat has a backward direction. Backward
 * repeats that are not part of an ending can use the times
 * attribute to indicate the number of times the repeated section
 * is played. The winged attribute indicates whether the repeat
 * has winged extensions that appear above and below the barline.
 * The straight and curved values represent single wings, while
 * the double-straight and double-curved values represent double
 * wings. The none value indicates no wings and is the default.
 */
export class Repeat {
    mixin IRepeat;
    this(xmlNodePtr node) {
        bool foundWinged = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "times") {
                auto data = getString(ch, true);
                this.times = data;
            }
            if (ch.name.toString == "winged") {
                auto data = getWingedType(ch);
                this.winged = data;
                foundWinged = true;
            }
            if (ch.name.toString == "direction") {
                auto data = getDirectionTypeBg(ch);
                this.direction = data;
            }
        }
        if (!foundWinged) {
            winged = WingedType.None;
        }
    }
}

/**
 * Repeat marks. The start of the repeat has a forward direction
 * while the end of the repeat has a backward direction. Backward
 * repeats that are not part of an ending can use the times
 * attribute to indicate the number of times the repeated section
 * is played. The winged attribute indicates whether the repeat
 * has winged extensions that appear above and below the barline.
 * The straight and curved values represent single wings, while
 * the double-straight and double-curved values represent double
 * wings. The none value indicates no wings and is the default.
 */
mixin template IRepeat() {
    string times;
    WingedType winged;
    DirectionTypeBg direction;
}

/**
 * The tip-direction entity represents the direction in which
 * the tip of a stick or beater points, using Unicode arrow
 * terminology.
 */
export enum TipDirection {
    Right = 3,
    Northwest = 4,
    Southwest = 7,
    Down = 1,
    Northeast = 5,
    Southeast = 6,
    Up = 0,
    Left = 2
}

TipDirection getTipDirection(T)(T p) {
    string s = getString(p, true);
    if (s == "right") {
        return TipDirection.Right;
    }
    if (s == "northwest") {
        return TipDirection.Northwest;
    }
    if (s == "southwest") {
        return TipDirection.Southwest;
    }
    if (s == "down") {
        return TipDirection.Down;
    }
    if (s == "northeast") {
        return TipDirection.Northeast;
    }
    if (s == "southeast") {
        return TipDirection.Southeast;
    }
    if (s == "up") {
        return TipDirection.Up;
    }
    if (s == "left") {
        return TipDirection.Left;
    }
    assert(false, "Not reached");
}
/**
 * A direction is a musical indication that is not attached
 * to a specific note. Two or more may be combined to
 * indicate starts and stops of wedges, dashes, etc.
 * 
 * By default, a series of direction-type elements and a
 * series of child elements of a direction-type within a
 * single direction element follow one another in sequence
 * visually. For a series of direction-type children, non-
 * positional formatting attributes are carried over from
 * the previous element by default.
 */
export class Direction {
    mixin IDirection;
    this(xmlNodePtr node) {
        bool foundPlacement = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "voice") {
                auto data = getNumber(ch, true);
                this.voice = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "direction-type") {
                auto data = new DirectionType(ch) ;
                this.directionTypes ~= data;
            }
            if (ch.name.toString == "staff") {
                auto data = getNumber(ch, true);
                this.staff = data;
            }
            if (ch.name.toString == "offset") {
                auto data = new Offset(ch) ;
                this.offset = data;
            }
            if (ch.name.toString == "sound") {
                auto data = new Sound(ch) ;
                this.sound = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * A direction is a musical indication that is not attached
 * to a specific note. Two or more may be combined to
 * indicate starts and stops of wedges, dashes, etc.
 * 
 * By default, a series of direction-type elements and a
 * series of child elements of a direction-type within a
 * single direction element follow one another in sequence
 * visually. For a series of direction-type children, non-
 * positional formatting attributes are carried over from
 * the previous element by default.
 */
mixin template IDirection() {
    mixin IEditorialVoice;
    mixin IPlacement;
    mixin IDirective;
    DirectionType[] directionTypes;
    float staff;
    Offset offset;
    Sound sound;
}

/**
 * Textual direction types may have more than 1 component
 * due to multiple fonts. The dynamics element may also be
 * used in the notations element, and is defined in the
 * common.mod file.
 */
export class DirectionType {
    mixin IDirectionType;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "percussion") {
                auto data = new Percussion(ch) ;
                this.percussions ~= data;
            }
            if (ch.name.toString == "rehearsal") {
                auto data = new Rehearsal(ch) ;
                this.rehearsals ~= data;
            }
            if (ch.name.toString == "pedal") {
                auto data = new Pedal(ch) ;
                this.pedal = data;
            }
            if (ch.name.toString == "principal-voice") {
                auto data = new PrincipalVoice(ch) ;
                this.principalVoice = data;
            }
            if (ch.name.toString == "accordion-registration") {
                auto data = new AccordionRegistration(ch) ;
                this.accordionRegistration = data;
            }
            if (ch.name.toString == "eyeglasses") {
                auto data = new Eyeglasses(ch) ;
                this.eyeglasses = data;
            }
            if (ch.name.toString == "image") {
                auto data = new Image(ch) ;
                this.image = data;
            }
            if (ch.name.toString == "harp-pedals") {
                auto data = new HarpPedals(ch) ;
                this.harpPedals = data;
            }
            if (ch.name.toString == "metronome") {
                auto data = new Metronome(ch) ;
                this.metronome = data;
            }
            if (ch.name.toString == "other-direction") {
                auto data = new OtherDirection(ch) ;
                this.otherDirection = data;
            }
            if (ch.name.toString == "segno") {
                auto data = new Segno(ch) ;
                this.segnos ~= data;
            }
            if (ch.name.toString == "scordatura") {
                auto data = new Scordatura(ch) ;
                this.scordatura = data;
            }
            if (ch.name.toString == "string-mute") {
                auto data = new StringMute(ch) ;
                this.stringMute = data;
            }
            if (ch.name.toString == "wedge") {
                auto data = new Wedge(ch) ;
                this.wedge = data;
            }
            if (ch.name.toString == "dashes") {
                auto data = new Dashes(ch) ;
                this.dashes = data;
            }
            if (ch.name.toString == "damp") {
                auto data = new Damp(ch) ;
                this.damp = data;
            }
            if (ch.name.toString == "bracket") {
                auto data = new Bracket(ch) ;
                this.bracket = data;
            }
            if (ch.name.toString == "dynamics") {
                auto data = new Dynamics(ch) ;
                this.dynamics = data;
            }
            if (ch.name.toString == "octave-shift") {
                auto data = new OctaveShift(ch) ;
                this.octaveShift = data;
            }
            if (ch.name.toString == "words") {
                auto data = new Words(ch) ;
                this.words ~= data;
            }
            if (ch.name.toString == "damp-all") {
                auto data = new DampAll(ch) ;
                this.dampAll = data;
            }
            if (ch.name.toString == "coda") {
                auto data = new Coda(ch) ;
                this.codas ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Textual direction types may have more than 1 component
 * due to multiple fonts. The dynamics element may also be
 * used in the notations element, and is defined in the
 * common.mod file.
 */
mixin template IDirectionType() {
    Percussion[] percussions;
    Rehearsal[] rehearsals;
    Pedal pedal;
    PrincipalVoice principalVoice;
    AccordionRegistration accordionRegistration;
    Eyeglasses eyeglasses;
    Image image;
    HarpPedals harpPedals;
    Metronome metronome;
    OtherDirection otherDirection;
    Segno[] segnos;
    Scordatura scordatura;
    StringMute stringMute;
    Wedge wedge;
    Dashes dashes;
    Damp damp;
    Bracket bracket;
    Dynamics dynamics;
    OctaveShift octaveShift;
    Words[] words;
    DampAll dampAll;
    Coda[] codas;
}

/**
 * Language is Italian ("it") by default. Enclosure is
 * square by default. Left justification is assumed if
 * not specified.
 */
export class Rehearsal {
    mixin IRehearsal;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * Language is Italian ("it") by default. Enclosure is
 * square by default. Left justification is assumed if
 * not specified.
 */
mixin template IRehearsal() {
    mixin ITextFormatting;
    string data;
}

/**
 * Left justification is assumed if not specified.
 * Language is Italian ("it") by default. Enclosure
 * is none by default.
 */
export class Words {
    mixin IWords;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * Left justification is assumed if not specified.
 * Language is Italian ("it") by default. Enclosure
 * is none by default.
 */
mixin template IWords() {
    mixin ITextFormatting;
    string data;
}

export enum WedgeType {
    Diminuendo = 1,
    Crescendo = 0,
    Stop = 2,
    Continue = 3
}

WedgeType getWedgeType(T)(T p) {
    string s = getString(p, true);
    if (s == "diminuendo") {
        return WedgeType.Diminuendo;
    }
    if (s == "crescendo") {
        return WedgeType.Crescendo;
    }
    if (s == "stop") {
        return WedgeType.Stop;
    }
    if (s == "continue") {
        return WedgeType.Continue;
    }
    assert(false, "Not reached");
}
/**
 * Wedge spread is measured in tenths of staff line space.
 * The type is crescendo for the start of a wedge that is
 * closed at the left side, and diminuendo for the start
 * of a wedge that is closed on the right side. Spread
 * values at the start of a crescendo wedge or end of a
 * diminuendo wedge are ignored. The niente attribute is yes
 * if a circle appears at the point of the wedge, indicating
 * a crescendo from nothing or diminuendo to nothing. It is
 * no by default, and used only when the type is crescendo,
 * or the type is stop for a wedge that began with a diminuendo
 * type. The line-type is solid by default. The continue type
 * is used for formatting wedges over a system break, or for
 * other situations where a single wedge is divided into
 * multiple segments.
 */
export class Wedge {
    mixin IWedge;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundNeinte = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "neinte") {
                auto data = getYesNo(ch, true);
                this.neinte = data;
                foundNeinte = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getWedgeType(ch);
                this.type = data;
            }
            if (ch.name.toString == "spread") {
                auto data = getNumber(ch, true);
                this.spread = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundNeinte) {
            neinte = false;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Wedge spread is measured in tenths of staff line space.
 * The type is crescendo for the start of a wedge that is
 * closed at the left side, and diminuendo for the start
 * of a wedge that is closed on the right side. Spread
 * values at the start of a crescendo wedge or end of a
 * diminuendo wedge are ignored. The niente attribute is yes
 * if a circle appears at the point of the wedge, indicating
 * a crescendo from nothing or diminuendo to nothing. It is
 * no by default, and used only when the type is crescendo,
 * or the type is stop for a wedge that began with a diminuendo
 * type. The line-type is solid by default. The continue type
 * is used for formatting wedges over a system break, or for
 * other situations where a single wedge is divided into
 * multiple segments.
 */
mixin template IWedge() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPosition;
    mixin IColor;
    float number_;
    bool neinte;
    WedgeType type;
    float spread;
}

/**
 * Dashes, used for instance with cresc. and dim. marks.
 * 
 */
export class Dashes {
    mixin IDashes;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Dashes, used for instance with cresc. and dim. marks.
 * 
 */
mixin template IDashes() {
    mixin IDashedFormatting;
    mixin IPosition;
    mixin IColor;
    float number_;
    StartStopContinue type;
}

export enum LineEndType {
    None = 4,
    Both = 2,
    Arrow = 3,
    Down = 1,
    Up = 0
}

LineEndType getLineEndType(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return LineEndType.None;
    }
    if (s == "both") {
        return LineEndType.Both;
    }
    if (s == "arrow") {
        return LineEndType.Arrow;
    }
    if (s == "down") {
        return LineEndType.Down;
    }
    if (s == "up") {
        return LineEndType.Up;
    }
    assert(false, "Not reached");
}
/**
 * Brackets are combined with words in a variety of
 * modern directions. The line-end attribute specifies
 * if there is a jog up or down (or both), an arrow,
 * or nothing at the start or end of the bracket. If
 * the line-end is up or down, the length of the jog
 * can be specified using the end-length attribute.
 * The line-type is solid by default.
 */
export class Bracket {
    mixin IBracket;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        bool foundLineType = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "end-length") {
                auto data = getNumber(ch, true);
                this.endLength = data;
            }
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "line-type") {
                auto data = getSolidDashedDottedWavy(ch);
                this.lineType = data;
                foundLineType = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopContinue(ch);
                this.type = data;
            }
            if (ch.name.toString == "line-end") {
                auto data = getLineEndType(ch);
                this.lineEnd = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
        if (!foundLineType) {
            lineType = SolidDashedDottedWavy.Solid;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Brackets are combined with words in a variety of
 * modern directions. The line-end attribute specifies
 * if there is a jog up or down (or both), an arrow,
 * or nothing at the start or end of the bracket. If
 * the line-end is up or down, the length of the jog
 * can be specified using the end-length attribute.
 * The line-type is solid by default.
 */
mixin template IBracket() {
    mixin ILineType;
    mixin IDashedFormatting;
    mixin IPosition;
    mixin IColor;
    float endLength;
    float number_;
    StartStopContinue type;
    LineEndType lineEnd;
}

export enum PedalType {
    Change = 3,
    Start = 0,
    Stop = 1,
    Continue = 2
}

PedalType getPedalType(T)(T p) {
    string s = getString(p, true);
    if (s == "change") {
        return PedalType.Change;
    }
    if (s == "start") {
        return PedalType.Start;
    }
    if (s == "stop") {
        return PedalType.Stop;
    }
    if (s == "continue") {
        return PedalType.Continue;
    }
    assert(false, "Not reached");
}
/**
 * Piano pedal marks. The line attribute is yes if pedal
 * lines are used. The sign attribute is yes if Ped and *
 * signs are used. For MusicXML 2.0 compatibility, the sign
 * attribute is yes by default if the line attribute is no,
 * and is no by default if the line attribute is yes. The
 * change and continue types are used when the line attribute
 * is yes. The change type indicates a pedal lift and retake
 * indicated with an inverted V marking. The continue type
 * allows more precise formatting across system breaks and for
 * more complex pedaling lines. The alignment attributes are
 * ignored if the line attribute is yes.
 */
export class Pedal {
    mixin IPedal;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "line") {
                auto data = getYesNo(ch, true);
                this.line = data;
            }
            if (ch.name.toString == "sign") {
                auto data = getYesNo(ch, true);
                this.sign = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "type") {
                auto data = getPedalType(ch);
                this.type = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * Piano pedal marks. The line attribute is yes if pedal
 * lines are used. The sign attribute is yes if Ped and *
 * signs are used. For MusicXML 2.0 compatibility, the sign
 * attribute is yes by default if the line attribute is no,
 * and is no by default if the line attribute is yes. The
 * change and continue types are used when the line attribute
 * is yes. The change type indicates a pedal lift and retake
 * indicated with an inverted V marking. The continue type
 * allows more precise formatting across system breaks and for
 * more complex pedaling lines. The alignment attributes are
 * ignored if the line attribute is yes.
 */
mixin template IPedal() {
    mixin IPrintStyleAlign;
    bool line;
    bool sign;
    PedalType type;
}

/**
 * Metronome marks and other metric relationships.
 * 
 * The beat-unit values are the same as for a type element,
 * and the beat-unit-dot works like the dot element. The
 * per-minute element can be a number, or a text description
 * including numbers. The parentheses attribute indicates
 * whether or not to put the metronome mark in parentheses;
 * its value is no if not specified. If a font is specified for
 * the per-minute element, it overrides the font specified for
 * the overall metronome element. This allows separate
 * specification of a music font for beat-unit and a text
 * font for the numeric value in cases where a single
 * metronome font is not used.
 * 
 * The metronome-note and metronome-relation elements
 * allow for the specification of more complicated metric
 * relationships, such as swing tempo marks where
 * two eighths are equated to a quarter note / eighth note
 * triplet. The metronome-type, metronome-beam, and
 * metronome-dot elements work like the type, beam, and
 * dot elements. The metronome-tuplet element uses the
 * same element structure as the time-modification element
 * along with some attributes from the tuplet element. The
 * metronome-relation element describes the relationship
 * symbol that goes between the two sets of metronome-note
 * elements. The currently allowed value is equals, but this
 * may expand in future versions. If the element is empty,
 * the equals value is used. The metronome-relation and
 * the following set of metronome-note elements are optional
 * to allow display of an isolated Grundschlagnote.
 */
export class Metronome {
    mixin IMetronome;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "metronome-note") {
                auto data = new MetronomeNote(ch) ;
                this.metronomeNotes ~= data;
            }
            if (ch.name.toString == "per-minute") {
                auto data = new PerMinute(ch) ;
                this.perMinute = data;
            }
            if (ch.name.toString == "beat-unit") {
                auto data = getString(ch, true);
                this.beatUnit = data;
            }
            if (ch.name.toString == "beat-unit-dot") {
                auto data = new BeatUnitDot(ch) ;
                this.beatUnitDots ~= data;
            }
            if (ch.name.toString == "metronome-relation") {
                auto data = getString(ch, true);
                this.metronomeRelation = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "parentheses") {
                auto data = getYesNo(ch, true);
                this.parentheses = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 * Metronome marks and other metric relationships.
 * 
 * The beat-unit values are the same as for a type element,
 * and the beat-unit-dot works like the dot element. The
 * per-minute element can be a number, or a text description
 * including numbers. The parentheses attribute indicates
 * whether or not to put the metronome mark in parentheses;
 * its value is no if not specified. If a font is specified for
 * the per-minute element, it overrides the font specified for
 * the overall metronome element. This allows separate
 * specification of a music font for beat-unit and a text
 * font for the numeric value in cases where a single
 * metronome font is not used.
 * 
 * The metronome-note and metronome-relation elements
 * allow for the specification of more complicated metric
 * relationships, such as swing tempo marks where
 * two eighths are equated to a quarter note / eighth note
 * triplet. The metronome-type, metronome-beam, and
 * metronome-dot elements work like the type, beam, and
 * dot elements. The metronome-tuplet element uses the
 * same element structure as the time-modification element
 * along with some attributes from the tuplet element. The
 * metronome-relation element describes the relationship
 * symbol that goes between the two sets of metronome-note
 * elements. The currently allowed value is equals, but this
 * may expand in future versions. If the element is empty,
 * the equals value is used. The metronome-relation and
 * the following set of metronome-note elements are optional
 * to allow display of an isolated Grundschlagnote.
 */
mixin template IMetronome() {
    mixin IPrintStyleAlign;
    mixin IJustify;
    MetronomeNote[] metronomeNotes;
    PerMinute perMinute;
    bool parentheses;
    string beatUnit;
    BeatUnitDot[] beatUnitDots;
    string metronomeRelation;
}

export class BeatUnitDot {
    mixin IBeatUnitDot;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template IBeatUnitDot() {
}

export class PerMinute {
    mixin IPerMinute;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
    }
}

mixin template IPerMinute() {
    mixin IFont;
    string data;
}

export class MetronomeNote {
    mixin IMetronomeNote;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "metronome-dot") {
                auto data = new MetronomeDot(ch) ;
                this.metronomeDots ~= data;
            }
            if (ch.name.toString == "metronome-beam") {
                auto data = new MetronomeBeam(ch) ;
                this.metronomeBeams ~= data;
            }
            if (ch.name.toString == "metronome-type") {
                auto data = getString(ch, true);
                this.metronomeType = data;
            }
            if (ch.name.toString == "metronome-tuplet") {
                auto data = new MetronomeTuplet(ch) ;
                this.metronomeTuplet = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template IMetronomeNote() {
    MetronomeDot[] metronomeDots;
    MetronomeBeam[] metronomeBeams;
    string metronomeType;
    MetronomeTuplet metronomeTuplet;
}

export class MetronomeDot {
    mixin IMetronomeDot;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template IMetronomeDot() {
}

export class MetronomeBeam {
    mixin IMetronomeBeam;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundNumber_) {
            number_ = 1;
        }
    }
}

mixin template IMetronomeBeam() {
    float number_;
    string data;
}

export class MetronomeTuplet {
    mixin IMetronomeTuplet;
    this(xmlNodePtr node) {
        bool foundBracket = false;
        bool foundShowNumber = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "actual-notes") {
                auto data = new ActualNotes(ch) ;
                this.actualNotes = data;
            }
            if (ch.name.toString == "normal-type") {
                auto data = getString(ch, true);
                this.normalType = data;
            }
            if (ch.name.toString == "normal-notes") {
                auto data = new NormalNotes(ch) ;
                this.normalNotes = data;
            }
            if (ch.name.toString == "normal-dot") {
                auto data = new NormalDot(ch) ;
                this.normalDots ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "bracket") {
                auto data = getYesNo(ch, true);
                this.bracket = data;
                foundBracket = true;
            }
            if (ch.name.toString == "show-number") {
                auto data = getActualBothNone(ch);
                this.showNumber = data;
                foundShowNumber = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        if (!foundBracket) {
            bracket = false;
        }
        if (!foundShowNumber) {
            showNumber = ActualBothNone.Both;
        }
    }
}

mixin template IMetronomeTuplet() {
    ActualNotes actualNotes;
    bool bracket;
    ActualBothNone showNumber;
    string normalType;
    StartStop type;
    NormalNotes normalNotes;
    NormalDot[] normalDots;
}

export enum OctaveShiftType {
    Down = 2,
    Stop = 3,
    Up = 1,
    Continue = 4
}

OctaveShiftType getOctaveShiftType(T)(T p) {
    string s = getString(p, true);
    if (s == "down") {
        return OctaveShiftType.Down;
    }
    if (s == "stop") {
        return OctaveShiftType.Stop;
    }
    if (s == "up") {
        return OctaveShiftType.Up;
    }
    if (s == "continue") {
        return OctaveShiftType.Continue;
    }
    assert(false, "Not reached");
}
/**
 * Octave shifts indicate where notes are shifted up or down
 * from their true pitched values because of printing
 * difficulty. Thus a treble clef line noted with 8va will
 * be indicated with an octave-shift down from the pitch
 * data indicated in the notes. A size of 8 indicates one
 * octave; a size of 15 indicates two octaves.
 */
export class OctaveShift {
    mixin IOctaveShift;
    this(xmlNodePtr node) {
        bool foundSize = false;
        bool foundDashLength = false;
        bool foundSpaceLength = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "size") {
                auto data = getNumber(ch, true);
                this.size = data;
                foundSize = true;
            }
            if (ch.name.toString == "dash-length") {
                auto data = getNumber(ch, true);
                this.dashLength = data;
                foundDashLength = true;
            }
            if (ch.name.toString == "space-length") {
                auto data = getNumber(ch, true);
                this.spaceLength = data;
                foundSpaceLength = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getOctaveShiftType(ch);
                this.type = data;
            }
        }
        if (!foundSize) {
            size = 8;
        }
        if (!foundDashLength) {
            dashLength = 1;
        }
        if (!foundSpaceLength) {
            spaceLength = 1;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Octave shifts indicate where notes are shifted up or down
 * from their true pitched values because of printing
 * difficulty. Thus a treble clef line noted with 8va will
 * be indicated with an octave-shift down from the pitch
 * data indicated in the notes. A size of 8 indicates one
 * octave; a size of 15 indicates two octaves.
 */
mixin template IOctaveShift() {
    mixin IDashedFormatting;
    mixin IPrintStyle;
    float number_;
    float size;
    OctaveShiftType type;
}

/**
 * The harp-pedals element is used to create harp pedal
 * diagrams. The pedal-step and pedal-alter elements use
 * the same values as the step and alter elements. For
 * easiest reading, the pedal-tuning elements should follow
 * standard harp pedal order, with pedal-step values of
 * D, C, B, E, F, G, and A.
 */
export class HarpPedals {
    mixin IHarpPedals;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "pedal-tuning") {
                auto data = new PedalTuning(ch) ;
                this.pedalTunings ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The harp-pedals element is used to create harp pedal
 * diagrams. The pedal-step and pedal-alter elements use
 * the same values as the step and alter elements. For
 * easiest reading, the pedal-tuning elements should follow
 * standard harp pedal order, with pedal-step values of
 * D, C, B, E, F, G, and A.
 */
mixin template IHarpPedals() {
    mixin IPrintStyleAlign;
    PedalTuning[] pedalTunings;
}

export class PedalTuning {
    mixin IPedalTuning;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "pedal-step") {
                auto data = getString(ch, true);
                this.pedalStep = data;
            }
            if (ch.name.toString == "pedal-alter") {
                auto data = getString(ch, true);
                this.pedalAlter = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template IPedalTuning() {
    string pedalStep;
    string pedalAlter;
}

/**
 * Harp damping marks
 */
export class Damp {
    mixin IDamp;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * Harp damping marks
 */
mixin template IDamp() {
    mixin IPrintStyleAlign;
}

export class DampAll {
    mixin IDampAll;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

mixin template IDampAll() {
    mixin IPrintStyleAlign;
}

export class Eyeglasses {
    mixin IEyeglasses;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

mixin template IEyeglasses() {
    mixin IPrintStyleAlign;
}

export class StringMute {
    mixin IStringMute;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

mixin template IStringMute() {
    mixin IPrintStyleAlign;
    string type;
}

/**
 * Scordatura string tunings are represented by a series
 * of accord elements. The tuning-step, tuning-alter,
 * and tuning-octave elements are also used with the
 * staff-tuning element, and are defined in the common.mod
 * file. Strings are numbered from high to low.
 */
export class Scordatura {
    mixin IScordatura;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "accord") {
                auto data = new Accord(ch) ;
                this.accords ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Scordatura string tunings are represented by a series
 * of accord elements. The tuning-step, tuning-alter,
 * and tuning-octave elements are also used with the
 * staff-tuning element, and are defined in the common.mod
 * file. Strings are numbered from high to low.
 */
mixin template IScordatura() {
    Accord[] accords;
}

/**
 * Scordatura string tunings are represented by a series
 * of accord elements. The tuning-step, tuning-alter,
 * and tuning-octave elements are also used with the
 * staff-tuning element, and are defined in the common.mod
 * file. Strings are numbered from high to low.
 */
export class Accord {
    mixin IAccord;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "tuning-alter") {
                auto data = new TuningAlter(ch) ;
                this.tuningAlter = data;
            }
            if (ch.name.toString == "tuning-step") {
                auto data = getString(ch, true);
                this.tuningStep = data;
            }
            if (ch.name.toString == "tuning-octave") {
                auto data = new TuningOctave(ch) ;
                this.tuningOctave = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "string") {
                auto data = getString(ch, true);
                this.string_ = data;
            }
        }
    }
}

/**
 * Scordatura string tunings are represented by a series
 * of accord elements. The tuning-step, tuning-alter,
 * and tuning-octave elements are also used with the
 * staff-tuning element, and are defined in the common.mod
 * file. Strings are numbered from high to low.
 */
mixin template IAccord() {
    TuningAlter tuningAlter;
    string string_;
    string tuningStep;
    TuningOctave tuningOctave;
}

/**
 * The image element is used to include graphical images
 * in a score. The required source attribute is the URL
 * for the image file. The required type attribute is the
 * MIME type for the image file format. Typical choices
 * include application/postscript, image/gif, image/jpeg,
 * image/png, and image/tiff.
 */
export class Image {
    mixin IImage;
    this(xmlNodePtr node) {
        bool foundHalign = false;
        bool foundValignImage = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign-image") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valignImage = data;
                foundValignImage = true;
            }
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
            if (ch.name.toString == "source") {
                auto data = getString(ch, true);
                this.source = data;
            }
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValignImage) {
            valignImage = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The image element is used to include graphical images
 * in a score. The required source attribute is the URL
 * for the image file. The required type attribute is the
 * MIME type for the image file format. Typical choices
 * include application/postscript, image/gif, image/jpeg,
 * image/png, and image/tiff.
 */
mixin template IImage() {
    mixin IPosition;
    mixin IHalign;
    mixin IValignImage;
    string type;
    string source;
}

export enum VoiceSymbol {
    None = 4,
    Hauptstimme = 1,
    Nebenstimme = 2,
    Plain = 3
}

VoiceSymbol getVoiceSymbol(T)(T p) {
    string s = getString(p, true);
    if (s == "none") {
        return VoiceSymbol.None;
    }
    if (s == "Hauptstimme") {
        return VoiceSymbol.Hauptstimme;
    }
    if (s == "Nebenstimme") {
        return VoiceSymbol.Nebenstimme;
    }
    if (s == "plain") {
        return VoiceSymbol.Plain;
    }
    assert(false, "Not reached");
}
/**
 * The principal-voice element represents principal and
 * secondary voices in a score, either for analysis or
 * for square bracket symbols that appear in a score.
 * The symbol attribute indicates the type of symbol used at
 * the start of the principal-voice. Valid values are
 * Hauptstimme, Nebenstimme, plain (for a plain square
 * bracket), and none. The content of the principal-voice
 * element is used for analysis and may be any text value.
 * When used for analysis separate from any printed score
 * markings, the symbol attribute should be set to "none".
 */
export class PrincipalVoice {
    mixin IPrincipalVoice;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "symbol") {
                auto data = getVoiceSymbol(ch);
                this.symbol = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, false);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The principal-voice element represents principal and
 * secondary voices in a score, either for analysis or
 * for square bracket symbols that appear in a score.
 * The symbol attribute indicates the type of symbol used at
 * the start of the principal-voice. Valid values are
 * Hauptstimme, Nebenstimme, plain (for a plain square
 * bracket), and none. The content of the principal-voice
 * element is used for analysis and may be any text value.
 * When used for analysis separate from any printed score
 * markings, the symbol attribute should be set to "none".
 */
mixin template IPrincipalVoice() {
    mixin IPrintStyleAlign;
    VoiceSymbol symbol;
    string data;
    StartStop type;
}

/**
 * The accordion-registration element is use for accordion
 * registration symbols. These are circular symbols divided
 * horizontally into high, middle, and low sections that
 * correspond to 4', 8', and 16' pipes. Each accordion-high,
 * accordion-middle, and accordion-low element represents
 * the presence of one or more dots in the registration
 * diagram. The accordion-middle element may have text
 * values of 1, 2, or 3, corresponding to have 1 to 3 dots
 * in the middle section. An accordion-registration element
 * needs to have at least one of the child elements present.
 */
export class AccordionRegistration {
    mixin IAccordionRegistration;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "accordion-middle") {
                auto data = getString(ch, true);
                this.accordionMiddle = data;
            }
            if (ch.name.toString == "accordion-high") {
                auto data = true;
                this.accordionHigh = data;
            }
            if (ch.name.toString == "accordion-low") {
                auto data = true;
                this.accordionLow = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The accordion-registration element is use for accordion
 * registration symbols. These are circular symbols divided
 * horizontally into high, middle, and low sections that
 * correspond to 4', 8', and 16' pipes. Each accordion-high,
 * accordion-middle, and accordion-low element represents
 * the presence of one or more dots in the registration
 * diagram. The accordion-middle element may have text
 * values of 1, 2, or 3, corresponding to have 1 to 3 dots
 * in the middle section. An accordion-registration element
 * needs to have at least one of the child elements present.
 */
mixin template IAccordionRegistration() {
    mixin IPrintStyleAlign;
    string accordionMiddle;
    bool accordionHigh;
    bool accordionLow;
}

/**
 * The percussion element is used to define percussion
 * pictogram symbols. Definitions for these symbols can be
 * found in Kurt Stone's "Music Notation in the Twentieth
 * Century" on pages 206-212 and 223. Some values are
 * added to these based on how usage has evolved in
 * the 30 years since Stone's book was published.
 */
export class Percussion {
    mixin IPercussion;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "stick-location") {
                auto data = getString(ch, true);
                this.stickLocation = data;
            }
            if (ch.name.toString == "other-percussion") {
                auto data = getString(ch, true);
                this.otherPercussion = data;
            }
            if (ch.name.toString == "wood") {
                auto data = getString(ch, true);
                this.wood = data;
            }
            if (ch.name.toString == "effect") {
                auto data = getString(ch, true);
                this.effect = data;
            }
            if (ch.name.toString == "glass") {
                auto data = getString(ch, true);
                this.glass = data;
            }
            if (ch.name.toString == "timpani") {
                auto data = new Timpani(ch) ;
                this.timpani = data;
            }
            if (ch.name.toString == "stick") {
                auto data = new Stick(ch) ;
                this.stick = data;
            }
            if (ch.name.toString == "metal") {
                auto data = getString(ch, true);
                this.metal = data;
            }
            if (ch.name.toString == "pitched") {
                auto data = getString(ch, true);
                this.pitched = data;
            }
            if (ch.name.toString == "membrane") {
                auto data = getString(ch, true);
                this.membrane = data;
            }
            if (ch.name.toString == "beater") {
                auto data = new Beater(ch) ;
                this.beater = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

/**
 * The percussion element is used to define percussion
 * pictogram symbols. Definitions for these symbols can be
 * found in Kurt Stone's "Music Notation in the Twentieth
 * Century" on pages 206-212 and 223. Some values are
 * added to these based on how usage has evolved in
 * the 30 years since Stone's book was published.
 */
mixin template IPercussion() {
    mixin IPrintStyleAlign;
    mixin IEnclosure;
    string stickLocation;
    string otherPercussion;
    string wood;
    string effect;
    string glass;
    Timpani timpani;
    Stick stick;
    string metal;
    string pitched;
    string membrane;
    Beater beater;
}

/**
 * The timpani element represents the timpani pictogram.
 * 
 */
export class Timpani {
    mixin ITimpani;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The timpani element represents the timpani pictogram.
 * 
 */
mixin template ITimpani() {
}

/**
 * The beater element represents pictograms for beaters,
 * mallets, and sticks that do not have different materials
 * represented in the pictogram. Valid values are bow,
 * chime hammer, coin, finger, fingernail, fist,
 * guiro scraper, hammer, hand, jazz stick, knitting needle,
 * metal hammer, snare stick, spoon mallet, triangle beater,
 * triangle beater plain, and wire brush. The jazz stick value
 * refers to Stone's plastic tip snare stick. The triangle
 * beater plain value refers to the plain line version of the
 * pictogram. The finger and hammer values are in addition
 * to Stone's list. The tip attribute represents the direction
 * in which the tip of a beater points.
 */
export class Beater {
    mixin IBeater;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "tip") {
                auto data = getTipDirection(ch);
                this.tip = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
    }
}

/**
 * The beater element represents pictograms for beaters,
 * mallets, and sticks that do not have different materials
 * represented in the pictogram. Valid values are bow,
 * chime hammer, coin, finger, fingernail, fist,
 * guiro scraper, hammer, hand, jazz stick, knitting needle,
 * metal hammer, snare stick, spoon mallet, triangle beater,
 * triangle beater plain, and wire brush. The jazz stick value
 * refers to Stone's plastic tip snare stick. The triangle
 * beater plain value refers to the plain line version of the
 * pictogram. The finger and hammer values are in addition
 * to Stone's list. The tip attribute represents the direction
 * in which the tip of a beater points.
 */
mixin template IBeater() {
    string data;
    TipDirection tip;
}

/**
 * The stick element represents pictograms where the material
 * in the stick, mallet, or beater is included. Valid values
 * for stick-type are bass drum, double bass drum, timpani,
 * xylophone, and yarn. Valid values for stick-material are
 * soft, medium, hard, shaded, and x. The shaded and x values
 * reflect different uses for brass, wood, and steel core
 * beaters of different types. The tip attribute represents
 * the direction in which the tip of a stick points.
 */
export class Stick {
    mixin IStick;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "stick-material") {
                auto data = getString(ch, true);
                this.stickMaterial = data;
            }
            if (ch.name.toString == "stick-type") {
                auto data = getString(ch, true);
                this.stickType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "tip") {
                auto data = getTipDirection(ch);
                this.tip = data;
            }
        }
    }
}

/**
 * The stick element represents pictograms where the material
 * in the stick, mallet, or beater is included. Valid values
 * for stick-type are bass drum, double bass drum, timpani,
 * xylophone, and yarn. Valid values for stick-material are
 * soft, medium, hard, shaded, and x. The shaded and x values
 * reflect different uses for brass, wood, and steel core
 * beaters of different types. The tip attribute represents
 * the direction in which the tip of a stick points.
 */
mixin template IStick() {
    string stickMaterial;
    string stickType;
    TipDirection tip;
}

/**
 * An offset is represented in terms of divisions, and
 * indicates where the direction will appear relative to
 * the current musical location. This affects the visual
 * appearance of the direction. If the sound attribute is
 * "yes", then the offset affects playback too. If the sound
 * attribute is "no", then any sound associated with the
 * direction takes effect at the current location. The sound
 * attribute is "no" by default for compatibility with earlier
 * versions of the MusicXML format. If an element within a
 * direction includes a default-x attribute, the offset value
 * will be ignored when determining the appearance of that
 * element.
 */
export class Offset {
    mixin IOffset;
    this(xmlNodePtr node) {
        bool foundSound = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "sound") {
                auto data = getYesNo(ch, true);
                this.sound = data;
                foundSound = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundSound) {
            sound = false;
        }
    }
}

/**
 * An offset is represented in terms of divisions, and
 * indicates where the direction will appear relative to
 * the current musical location. This affects the visual
 * appearance of the direction. If the sound attribute is
 * "yes", then the offset affects playback too. If the sound
 * attribute is "no", then any sound associated with the
 * direction takes effect at the current location. The sound
 * attribute is "no" by default for compatibility with earlier
 * versions of the MusicXML format. If an element within a
 * direction includes a default-x attribute, the offset value
 * will be ignored when determining the appearance of that
 * element.
 */
mixin template IOffset() {
    string data;
    bool sound;
}

/**
 * The harmony elements are based on Humdrum's **harm
 * encoding, extended to support chord symbols in popular
 * music as well as functional harmony analysis in classical
 * music.
 * 
 * If there are alternate harmonies possible, this can be
 * specified using multiple harmony elements differentiated
 * by type. Explicit harmonies have all note present in the
 * music; implied have some notes missing but implied;
 * alternate represents alternate analyses.
 * 
 * The harmony object may be used for analysis or for
 * chord symbols. The print-object attribute controls
 * whether or not anything is printed due to the harmony
 * element. The print-frame attribute controls printing
 * of a frame or fretboard diagram. The print-style entity
 * sets the default for the harmony, but individual elements
 * can override this with their own print-style values.
 * 
 * A harmony element can contain many stacked chords (e.g.
 * V of II). A sequence of harmony-chord entities is used
 * for this type of secondary function, where V of II would
 * be represented by a harmony-chord with a V function
 * followed by a harmony-chord with a II function.
 */
export class HarmonyChord {
    mixin IHarmonyChord;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "root") {
                auto data = new Root(ch) ;
                this.root = data;
            }
            if (ch.name.toString == "function") {
                auto data = new Function(ch) ;
                this.function_ = data;
            }
            if (ch.name.toString == "kind") {
                auto data = new Kind(ch) ;
                this.kind = data;
            }
            if (ch.name.toString == "degree") {
                auto data = new Degree(ch) ;
                this.degree = data;
            }
            if (ch.name.toString == "inversion") {
                auto data = new Inversion(ch) ;
                this.inversion = data;
            }
            if (ch.name.toString == "bass") {
                auto data = new Bass(ch) ;
                this.bass = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The harmony elements are based on Humdrum's **harm
 * encoding, extended to support chord symbols in popular
 * music as well as functional harmony analysis in classical
 * music.
 * 
 * If there are alternate harmonies possible, this can be
 * specified using multiple harmony elements differentiated
 * by type. Explicit harmonies have all note present in the
 * music; implied have some notes missing but implied;
 * alternate represents alternate analyses.
 * 
 * The harmony object may be used for analysis or for
 * chord symbols. The print-object attribute controls
 * whether or not anything is printed due to the harmony
 * element. The print-frame attribute controls printing
 * of a frame or fretboard diagram. The print-style entity
 * sets the default for the harmony, but individual elements
 * can override this with their own print-style values.
 * 
 * A harmony element can contain many stacked chords (e.g.
 * V of II). A sequence of harmony-chord entities is used
 * for this type of secondary function, where V of II would
 * be represented by a harmony-chord with a V function
 * followed by a harmony-chord with a II function.
 */
mixin template IHarmonyChord() {
    Root root;
    Function function_;
    Kind kind;
    Degree degree;
    Inversion inversion;
    Bass bass;
}

export enum ExplicitImpliedAlternate {
    Explicit = 1,
    Implied = 2,
    Alternate = 3
}

ExplicitImpliedAlternate getExplicitImpliedAlternate(T)(T p) {
    string s = getString(p, true);
    if (s == "explicit") {
        return ExplicitImpliedAlternate.Explicit;
    }
    if (s == "implied") {
        return ExplicitImpliedAlternate.Implied;
    }
    if (s == "alternate") {
        return ExplicitImpliedAlternate.Alternate;
    }
    assert(false, "Not reached");
}
export class Harmony {
    mixin IHarmony;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPlacement = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "frame") {
                auto data = new Frame(ch) ;
                this.frame = data;
            }
            if (ch.name.toString == "root") {
                auto data = new Root(ch) ;
                this.root = data;
            }
            if (ch.name.toString == "function") {
                auto data = new Function(ch) ;
                this.function_ = data;
            }
            if (ch.name.toString == "kind") {
                auto data = new Kind(ch) ;
                this.kind = data;
            }
            if (ch.name.toString == "degree") {
                auto data = new Degree(ch) ;
                this.degree = data;
            }
            if (ch.name.toString == "inversion") {
                auto data = new Inversion(ch) ;
                this.inversion = data;
            }
            if (ch.name.toString == "bass") {
                auto data = new Bass(ch) ;
                this.bass = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "staff") {
                auto data = getNumber(ch, true);
                this.staff = data;
            }
            if (ch.name.toString == "offset") {
                auto data = new Offset(ch) ;
                this.offset = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-frame") {
                auto data = getYesNo(ch, true);
                this.printFrame = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "placement") {
                auto data = getAboveBelow(ch);
                this.placement = data;
                foundPlacement = true;
            }
            if (ch.name.toString == "type") {
                auto data = getExplicitImpliedAlternate(ch);
                this.harmonyType = data;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPlacement) {
            placement = AboveBelow.Unspecified;
        }
    }
}

mixin template IHarmony() {
    mixin IHarmonyChord;
    mixin IEditorial;
    mixin IPrintObject;
    mixin IPrintStyle;
    mixin IPlacement;
    Frame frame;
    bool printFrame;
    float staff;
    ExplicitImpliedAlternate harmonyType;
    Offset offset;
}

/**
 * A root is a pitch name like C, D, E, where a function
 * is an indication like I, II, III. Root is generally
 * used with pop chord symbols, function with classical
 * functional harmony. It is an either/or choice to avoid
 * data inconsistency. Function requires that the key be
 * specified in the encoding.
 * 
 * The root element has a root-step and optional root-alter
 * similar to the step and alter elements in a pitch, but
 * renamed to distinguish the different musical meanings.
 * The root-step text element indicates how the root should
 * appear in a score if not using the element contents.
 * In some chord styles, this will include the root-alter
 * information as well. In that case, the print-object
 * attribute of the root-alter element can be set to no.
 * The root-alter location attribute indicates whether
 * the alteration should appear to the left or the right
 * of the root-step; it is right by default.
 */
export class Root {
    mixin IRoot;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "root-step") {
                auto data = new RootStep(ch) ;
                this.rootStep = data;
            }
            if (ch.name.toString == "root-alter") {
                auto data = new RootAlter(ch) ;
                this.rootAlter = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * A root is a pitch name like C, D, E, where a function
 * is an indication like I, II, III. Root is generally
 * used with pop chord symbols, function with classical
 * functional harmony. It is an either/or choice to avoid
 * data inconsistency. Function requires that the key be
 * specified in the encoding.
 * 
 * The root element has a root-step and optional root-alter
 * similar to the step and alter elements in a pitch, but
 * renamed to distinguish the different musical meanings.
 * The root-step text element indicates how the root should
 * appear in a score if not using the element contents.
 * In some chord styles, this will include the root-alter
 * information as well. In that case, the print-object
 * attribute of the root-alter element can be set to no.
 * The root-alter location attribute indicates whether
 * the alteration should appear to the left or the right
 * of the root-step; it is right by default.
 */
mixin template IRoot() {
    RootStep rootStep;
    RootAlter rootAlter;
}

export class RootStep {
    mixin IRootStep;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IRootStep() {
    mixin IPrintStyle;
    string text;
    string data;
}

export class RootAlter {
    mixin IRootAlter;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "location") {
                auto data = getLeftRight(ch);
                this.location = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IRootAlter() {
    mixin IPrintObject;
    mixin IPrintStyle;
    LeftRight location;
    string data;
}

export class Function {
    mixin IFunction;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IFunction() {
    mixin IPrintStyle;
    string data;
}

/**
 * Kind indicates the type of chord. Degree elements
 * can then add, subtract, or alter from these
 * starting points. Values include:
 * 
 * Triads:
 * major (major third, perfect fifth)
 * minor (minor third, perfect fifth)
 * augmented (major third, augmented fifth)
 * diminished (minor third, diminished fifth)
 * Sevenths:
 * dominant (major triad, minor seventh)
 * major-seventh (major triad, major seventh)
 * minor-seventh (minor triad, minor seventh)
 * diminished-seventh
 *     (diminished triad, diminished seventh)
 * augmented-seventh
 *     (augmented triad, minor seventh)
 * half-diminished
 *     (diminished triad, minor seventh)
 * major-minor
 *     (minor triad, major seventh)
 * Sixths:
 * major-sixth (major triad, added sixth)
 * minor-sixth (minor triad, added sixth)
 * Ninths:
 * dominant-ninth (dominant-seventh, major ninth)
 * major-ninth (major-seventh, major ninth)
 * minor-ninth (minor-seventh, major ninth)
 * 11ths (usually as the basis for alteration):
 * dominant-11th (dominant-ninth, perfect 11th)
 * major-11th (major-ninth, perfect 11th)
 * minor-11th (minor-ninth, perfect 11th)
 * 13ths (usually as the basis for alteration):
 * dominant-13th (dominant-11th, major 13th)
 * major-13th (major-11th, major 13th)
 * minor-13th (minor-11th, major 13th)
 * Suspended:
 * suspended-second (major second, perfect fifth)
 * suspended-fourth (perfect fourth, perfect fifth)
 * Functional sixths:
 * Neapolitan
 * Italian
 * French
 * German
 * Other:
 * pedal (pedal-point bass)
 * power (perfect fifth)
 * Tristan
 * 
 * The "other" kind is used when the harmony is entirely
 * composed of add elements. The "none" kind is used to
 * explicitly encode absence of chords or functional
 * harmony.
 * 
 * The attributes are used to indicate the formatting
 * of the symbol. Since the kind element is the constant
 * in all the harmony-chord entities that can make up
 * a polychord, many formatting attributes are here.
 * 
 * The use-symbols attribute is yes if the kind should be
 * represented when possible with harmony symbols rather
 * than letters and numbers. These symbols include:
 * 
 * major: a triangle, like Unicode 25B3
 * minor: -, like Unicode 002D
 * augmented: +, like Unicode 002B
 * diminished: °, like Unicode 00B0
 * half-diminished: ø, like Unicode 00F8
 * 
 * For the major-minor kind, only the minor symbol is used when
 * use-symbols is yes. The major symbol is set using the symbol
 * attribute in the degree-value element. The corresponding
 * degree-alter value will usually be 0 in this case.
 * 
 * The text attribute describes how the kind should be spelled
 * in a score. If use-symbols is yes, the value of the text
 * attribute follows the symbol. The stack-degrees attribute
 * is yes if the degree elements should be stacked above each
 * other. The parentheses-degrees attribute is yes if all the
 * degrees should be in parentheses. The bracket-degrees
 * attribute is yes if all the degrees should be in a bracket.
 * If not specified, these values are implementation-specific.
 * The alignment attributes are for the entire harmony-chord
 * entity of which this kind element is a part.
 */
export class Kind {
    mixin IKind;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "parentheses-degrees") {
                auto data = getYesNo(ch, true);
                this.parenthesesDegrees = data;
            }
            if (ch.name.toString == "use-symbols") {
                auto data = getYesNo(ch, true);
                this.useSymbols = data;
            }
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "stack-degrees") {
                auto data = getYesNo(ch, true);
                this.stackDegrees = data;
            }
            if (ch.name.toString == "bracket-degrees") {
                auto data = getYesNo(ch, true);
                this.bracketDegrees = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * Kind indicates the type of chord. Degree elements
 * can then add, subtract, or alter from these
 * starting points. Values include:
 * 
 * Triads:
 * major (major third, perfect fifth)
 * minor (minor third, perfect fifth)
 * augmented (major third, augmented fifth)
 * diminished (minor third, diminished fifth)
 * Sevenths:
 * dominant (major triad, minor seventh)
 * major-seventh (major triad, major seventh)
 * minor-seventh (minor triad, minor seventh)
 * diminished-seventh
 *     (diminished triad, diminished seventh)
 * augmented-seventh
 *     (augmented triad, minor seventh)
 * half-diminished
 *     (diminished triad, minor seventh)
 * major-minor
 *     (minor triad, major seventh)
 * Sixths:
 * major-sixth (major triad, added sixth)
 * minor-sixth (minor triad, added sixth)
 * Ninths:
 * dominant-ninth (dominant-seventh, major ninth)
 * major-ninth (major-seventh, major ninth)
 * minor-ninth (minor-seventh, major ninth)
 * 11ths (usually as the basis for alteration):
 * dominant-11th (dominant-ninth, perfect 11th)
 * major-11th (major-ninth, perfect 11th)
 * minor-11th (minor-ninth, perfect 11th)
 * 13ths (usually as the basis for alteration):
 * dominant-13th (dominant-11th, major 13th)
 * major-13th (major-11th, major 13th)
 * minor-13th (minor-11th, major 13th)
 * Suspended:
 * suspended-second (major second, perfect fifth)
 * suspended-fourth (perfect fourth, perfect fifth)
 * Functional sixths:
 * Neapolitan
 * Italian
 * French
 * German
 * Other:
 * pedal (pedal-point bass)
 * power (perfect fifth)
 * Tristan
 * 
 * The "other" kind is used when the harmony is entirely
 * composed of add elements. The "none" kind is used to
 * explicitly encode absence of chords or functional
 * harmony.
 * 
 * The attributes are used to indicate the formatting
 * of the symbol. Since the kind element is the constant
 * in all the harmony-chord entities that can make up
 * a polychord, many formatting attributes are here.
 * 
 * The use-symbols attribute is yes if the kind should be
 * represented when possible with harmony symbols rather
 * than letters and numbers. These symbols include:
 * 
 * major: a triangle, like Unicode 25B3
 * minor: -, like Unicode 002D
 * augmented: +, like Unicode 002B
 * diminished: °, like Unicode 00B0
 * half-diminished: ø, like Unicode 00F8
 * 
 * For the major-minor kind, only the minor symbol is used when
 * use-symbols is yes. The major symbol is set using the symbol
 * attribute in the degree-value element. The corresponding
 * degree-alter value will usually be 0 in this case.
 * 
 * The text attribute describes how the kind should be spelled
 * in a score. If use-symbols is yes, the value of the text
 * attribute follows the symbol. The stack-degrees attribute
 * is yes if the degree elements should be stacked above each
 * other. The parentheses-degrees attribute is yes if all the
 * degrees should be in parentheses. The bracket-degrees
 * attribute is yes if all the degrees should be in a bracket.
 * If not specified, these values are implementation-specific.
 * The alignment attributes are for the entire harmony-chord
 * entity of which this kind element is a part.
 */
mixin template IKind() {
    mixin IPrintStyle;
    mixin IHalign;
    mixin IValign;
    bool parenthesesDegrees;
    bool useSymbols;
    string text;
    string data;
    bool stackDegrees;
    bool bracketDegrees;
}

/**
 * Inversion is a number indicating which inversion is used:
 * 0 for root position, 1 for first inversion, etc.
 */
export class Inversion {
    mixin IInversion;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Inversion is a number indicating which inversion is used:
 * 0 for root position, 1 for first inversion, etc.
 */
mixin template IInversion() {
    mixin IPrintStyle;
    string data;
}

/**
 * Bass is used to indicate a bass note in popular music
 * chord symbols, e.g. G/C. It is generally not used in
 * functional harmony, as inversion is generally not used
 * in pop chord symbols. As with root, it is divided into
 * step and alter elements, similar to pitches. The attributes
 * for bass-step and bass-alter work the same way as
 * the corresponding attributes for root-step and root-alter.
 */
export class Bass {
    mixin IBass;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "bass-step") {
                auto data = new BassStep(ch) ;
                this.bassStep = data;
            }
            if (ch.name.toString == "bass-alter") {
                auto data = new BassAlter(ch) ;
                this.bassAlter = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Bass is used to indicate a bass note in popular music
 * chord symbols, e.g. G/C. It is generally not used in
 * functional harmony, as inversion is generally not used
 * in pop chord symbols. As with root, it is divided into
 * step and alter elements, similar to pitches. The attributes
 * for bass-step and bass-alter work the same way as
 * the corresponding attributes for root-step and root-alter.
 */
mixin template IBass() {
    BassStep bassStep;
    BassAlter bassAlter;
}

/**
 * Bass is used to indicate a bass note in popular music
 * chord symbols, e.g. G/C. It is generally not used in
 * functional harmony, as inversion is generally not used
 * in pop chord symbols. As with root, it is divided into
 * step and alter elements, similar to pitches. The attributes
 * for bass-step and bass-alter work the same way as
 * the corresponding attributes for root-step and root-alter.
 */
export class BassStep {
    mixin IBassStep;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * Bass is used to indicate a bass note in popular music
 * chord symbols, e.g. G/C. It is generally not used in
 * functional harmony, as inversion is generally not used
 * in pop chord symbols. As with root, it is divided into
 * step and alter elements, similar to pitches. The attributes
 * for bass-step and bass-alter work the same way as
 * the corresponding attributes for root-step and root-alter.
 */
mixin template IBassStep() {
    mixin IPrintStyle;
    string text;
    string data;
}

export class BassAlter {
    mixin IBassAlter;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "location") {
                auto data = getLeftRight(ch);
                this.location = data;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IBassAlter() {
    mixin IPrintObject;
    mixin IPrintStyle;
    LeftRight location;
    string data;
}

/**
 * The degree element is used to add, alter, or subtract
 * individual notes in the chord. The degree-value element
 * is a number indicating the degree of the chord (1 for
 * the root, 3 for third, etc). The degree-alter element
 * is like the alter element in notes: 1 for sharp, -1 for
 * flat, etc. The degree-type element can be add, alter, or
 * subtract. If the degree-type is alter or subtract, the
 * degree-alter is relative to the degree already in the
 * chord based on its kind element. If the degree-type is
 * add, the degree-alter is relative to a dominant chord
 * (major and perfect intervals except for a minor
 * seventh). The print-object attribute can be used to
 * keep the degree from printing separately when it has
 * already taken into account in the text attribute of
 * the kind element. The plus-minus attribute is used to
 * indicate if plus and minus symbols should be used
 * instead of sharp and flat symbols to display the degree
 * alteration; it is no by default.
 * 
 * The degree-value and degree-type text attributes specify
 * how the value and type of the degree should be displayed
 * in a score. The degree-value symbol attribute indicates
 * that a symbol should be used in specifying the degree.
 * If the symbol attribute is present, the value of the text
 * attribute follows the symbol.
 * 
 * A harmony of kind "other" can be spelled explicitly by
 * using a series of degree elements together with a root.
 */
export class Degree {
    mixin IDegree;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "degree-alter") {
                auto data = new DegreeAlter(ch) ;
                this.degreeAlter = data;
            }
            if (ch.name.toString == "degree-value") {
                auto data = new DegreeValue(ch) ;
                this.degreeValue = data;
            }
            if (ch.name.toString == "degree-type") {
                auto data = new DegreeType(ch) ;
                this.degreeType = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * The degree element is used to add, alter, or subtract
 * individual notes in the chord. The degree-value element
 * is a number indicating the degree of the chord (1 for
 * the root, 3 for third, etc). The degree-alter element
 * is like the alter element in notes: 1 for sharp, -1 for
 * flat, etc. The degree-type element can be add, alter, or
 * subtract. If the degree-type is alter or subtract, the
 * degree-alter is relative to the degree already in the
 * chord based on its kind element. If the degree-type is
 * add, the degree-alter is relative to a dominant chord
 * (major and perfect intervals except for a minor
 * seventh). The print-object attribute can be used to
 * keep the degree from printing separately when it has
 * already taken into account in the text attribute of
 * the kind element. The plus-minus attribute is used to
 * indicate if plus and minus symbols should be used
 * instead of sharp and flat symbols to display the degree
 * alteration; it is no by default.
 * 
 * The degree-value and degree-type text attributes specify
 * how the value and type of the degree should be displayed
 * in a score. The degree-value symbol attribute indicates
 * that a symbol should be used in specifying the degree.
 * If the symbol attribute is present, the value of the text
 * attribute follows the symbol.
 * 
 * A harmony of kind "other" can be spelled explicitly by
 * using a series of degree elements together with a root.
 */
mixin template IDegree() {
    mixin IPrintObject;
    DegreeAlter degreeAlter;
    DegreeValue degreeValue;
    DegreeType degreeType;
}

export enum ChordType {
    Augmented = 3,
    Diminished = 4,
    Major = 1,
    Minor = 2,
    HalfDiminished = 5
}

ChordType getChordType(T)(T p) {
    string s = getString(p, true);
    if (s == "augmented") {
        return ChordType.Augmented;
    }
    if (s == "diminished") {
        return ChordType.Diminished;
    }
    if (s == "major") {
        return ChordType.Major;
    }
    if (s == "minor") {
        return ChordType.Minor;
    }
    if (s == "half-diminished") {
        return ChordType.HalfDiminished;
    }
    assert(false, "Not reached");
}
export class DegreeValue {
    mixin IDegreeValue;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "symbol") {
                auto data = getChordType(ch);
                this.symbol = data;
            }
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IDegreeValue() {
    mixin IPrintStyle;
    ChordType symbol;
    string text;
    string data;
}

export class DegreeAlter {
    mixin IDegreeAlter;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "plus-minus") {
                auto data = getYesNo(ch, true);
                this.plusMinus = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IDegreeAlter() {
    mixin IPrintStyle;
    bool plusMinus;
    string data;
}

export class DegreeType {
    mixin IDegreeType;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

mixin template IDegreeType() {
    mixin IPrintStyle;
    string text;
    string data;
}

/**
 * The frame element represents a frame or fretboard diagram
 * used together with a chord symbol. The representation is
 * based on the NIFF guitar grid with additional information.
 * The frame-strings and frame-frets elements give the
 * overall size of the frame in vertical lines (strings) and
 * horizontal spaces (frets).
 * 
 * The frame element's unplayed attribute indicates what to
 * display above a string that has no associated frame-note
 * element. Typical values are x and the empty string. If the
 * attribute is not present, the display of the unplayed
 * string is application-defined.
 */
export class Frame {
    mixin IFrame;
    this(xmlNodePtr node) {
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValignImage = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "frame-strings") {
                auto data = getString(ch, true);
                this.frameStrings = data;
            }
            if (ch.name.toString == "frame-note") {
                auto data = new FrameNote(ch) ;
                this.frameNotes ~= data;
            }
            if (ch.name.toString == "frame-frets") {
                auto data = getString(ch, true);
                this.frameFrets = data;
            }
            if (ch.name.toString == "first-fret") {
                auto data = new FirstFret(ch) ;
                this.firstFret = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "unplayed") {
                auto data = getString(ch, true);
                this.unplayed = data;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign-image") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valignImage = data;
                foundValignImage = true;
            }
            if (ch.name.toString == "width") {
                auto data = getNumber(ch, true);
                this.width = data;
            }
            if (ch.name.toString == "height") {
                auto data = getNumber(ch, true);
                this.height = data;
            }
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValignImage) {
            valignImage = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The frame element represents a frame or fretboard diagram
 * used together with a chord symbol. The representation is
 * based on the NIFF guitar grid with additional information.
 * The frame-strings and frame-frets elements give the
 * overall size of the frame in vertical lines (strings) and
 * horizontal spaces (frets).
 * 
 * The frame element's unplayed attribute indicates what to
 * display above a string that has no associated frame-note
 * element. Typical values are x and the empty string. If the
 * attribute is not present, the display of the unplayed
 * string is application-defined.
 */
mixin template IFrame() {
    mixin IPosition;
    mixin IColor;
    mixin IHalign;
    mixin IValignImage;
    string frameStrings;
    FrameNote[] frameNotes;
    string unplayed;
    string frameFrets;
    FirstFret firstFret;
    float width;
    float height;
}

/**
 * The first-fret indicates which fret is shown in the top
 * space of the frame; it is fret 1 if the element is not
 * present. The optional text attribute indicates how this
 * is represented in the fret diagram, while the location
 * attribute indicates whether the text appears to the left
 * or right of the frame.
 */
export class FirstFret {
    mixin IFirstFret;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "text") {
                auto data = getString(ch, true);
                this.text = data;
            }
            if (ch.name.toString == "location") {
                auto data = getLeftRight(ch);
                this.location = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
    }
}

/**
 * The first-fret indicates which fret is shown in the top
 * space of the frame; it is fret 1 if the element is not
 * present. The optional text attribute indicates how this
 * is represented in the fret diagram, while the location
 * attribute indicates whether the text appears to the left
 * or right of the frame.
 */
mixin template IFirstFret() {
    string text;
    LeftRight location;
    string data;
}

/**
 * The frame-note element represents each note included in
 * the frame. The definitions for string, fret, and fingering
 * are found in the common.mod file. An open string will
 * have a fret value of 0, while a muted string will not be
 * associated with a frame-note element.
 */
export class FrameNote {
    mixin IFrameNote;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "barre") {
                auto data = new Barre(ch) ;
                this.barre = data;
            }
            if (ch.name.toString == "string") {
                auto data = new String(ch) ;
                this.string_ = data;
            }
            if (ch.name.toString == "fingering") {
                auto data = new Fingering(ch) ;
                this.fingering = data;
            }
            if (ch.name.toString == "fret") {
                auto data = new Fret(ch) ;
                this.fret = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The frame-note element represents each note included in
 * the frame. The definitions for string, fret, and fingering
 * are found in the common.mod file. An open string will
 * have a fret value of 0, while a muted string will not be
 * associated with a frame-note element.
 */
mixin template IFrameNote() {
    Barre barre;
    String string_;
    Fingering fingering;
    Fret fret;
}

/**
 * The barre element indicates placing a finger over
 * multiple strings on a single fret. The type is "start"
 * for the lowest pitched string (e.g., the string with
 * the highest MusicXML number) and is "stop" for the
 * highest pitched string.
 */
export class Barre {
    mixin IBarre;
    this(xmlNodePtr node) {
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The barre element indicates placing a finger over
 * multiple strings on a single fret. The type is "start"
 * for the lowest pitched string (e.g., the string with
 * the highest MusicXML number) and is "stop" for the
 * highest pitched string.
 */
mixin template IBarre() {
    mixin IColor;
    StartStop type;
}

/**
 * The grouping element is used for musical analysis. When
 * the element type is "start" or "single", it usually contains
 * one or more feature elements. The number attribute is used
 * for distinguishing between overlapping and hierarchical
 * groupings. The member-of attribute allows for easy
 * distinguishing of what grouping elements are in what
 * hierarchy. Feature elements contained within a "stoptype of grouping may be ignored.
 * 
 * This element is flexible to allow for non-standard analyses.
 * Future versions of the MusicXML format may add elements
 * that can represent more standardized categories of analysis"
 * data, allowing for easier data sharing.
 */
export class Grouping {
    mixin IGrouping;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "feature") {
                auto data = new Feature(ch) ;
                this.features ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStopSingle(ch);
                this.groupingType = data;
            }
            if (ch.name.toString == "member-of") {
                auto data = getString(ch, true);
                this.memberOf = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
    }
}

/**
 * The grouping element is used for musical analysis. When
 * the element type is "start" or "single", it usually contains
 * one or more feature elements. The number attribute is used
 * for distinguishing between overlapping and hierarchical
 * groupings. The member-of attribute allows for easy
 * distinguishing of what grouping elements are in what
 * hierarchy. Feature elements contained within a "stoptype of grouping may be ignored.
 * 
 * This element is flexible to allow for non-standard analyses.
 * Future versions of the MusicXML format may add elements
 * that can represent more standardized categories of analysis"
 * data, allowing for easier data sharing.
 */
mixin template IGrouping() {
    Feature[] features;
    float number_;
    StartStopSingle groupingType;
    string memberOf;
}

export class Feature {
    mixin IFeature;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
    }
}

mixin template IFeature() {
    string data;
    string type;
}

/**
 * The print element contains general printing parameters,
 * including the layout elements defined in the layout.mod
 * file. The part-name-display and part-abbreviation-display
 * elements used in the score.mod file may also be used here
 * to change how a part name or abbreviation is displayed over
 * the course of a piece. They take effect when the current
 * measure or a succeeding measure starts a new system.
 * 
 * The new-system and new-page attributes indicate whether
 * to force a system or page break, or to force the current
 * music onto the same system or page as the preceding music.
 * Normally this is the first music data within a measure.
 * If used in multi-part music, they should be placed in the
 * same positions within each part, or the results are
 * undefined. The page-number attribute sets the number of a
 * new page; it is ignored if new-page is not "yes". Version
 * 2.0 adds a blank-page attribute. This is a positive integer
 * value that specifies the number of blank pages to insert
 * before the current measure. It is ignored if new-page is
 * not "yes". These blank pages have no music, but may have
 * text or images specified by the credit element. This is
 * used to allow a combination of pages that are all text,
 * or all text and images, together with pages of music.
 * 
 * Staff spacing between multiple staves is measured in
 * tenths of staff lines (e.g. 100 = 10 staff lines). This is
 * deprecated as of Version 1.1; the staff-layout element
 * should be used instead. If both are present, the
 * staff-layout values take priority.
 * 
 * Layout elements in a print statement only apply to the
 * current page, system, staff, or measure. Music that
 * follows continues to take the default values from the
 * layout included in the defaults element.
 */
export class Print {
    mixin IPrint;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "measure-numbering") {
                auto data = new MeasureNumbering(ch) ;
                this.measureNumbering = data;
            }
            if (ch.name.toString == "part-name-display") {
                auto data = new PartNameDisplay(ch) ;
                this.partNameDisplay = data;
            }
            if (ch.name.toString == "measure-layout") {
                auto data = new MeasureLayout(ch) ;
                this.measureLayout = data;
            }
            if (ch.name.toString == "part-abbreviation-display") {
                auto data = new PartAbbreviationDisplay(ch) ;
                this.partAbbreviationDisplay = data;
            }
            if (ch.name.toString == "page-layout") {
                auto data = new PageLayout(ch) ;
                this.pageLayout = data;
            }
            if (ch.name.toString == "system-layout") {
                auto data = new SystemLayout(ch) ;
                this.systemLayout = data;
            }
            if (ch.name.toString == "staff-layout") {
                auto data = new StaffLayout(ch) ;
                this.staffLayouts ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "new-system") {
                auto data = getYesNo(ch, true);
                this.newSystem = data;
            }
            if (ch.name.toString == "new-page") {
                auto data = getYesNo(ch, true);
                this.newPage = data;
            }
            if (ch.name.toString == "blank-page") {
                auto data = getString(ch, true);
                this.blankPage = data;
            }
            if (ch.name.toString == "staff-spacing") {
                auto data = getNumber(ch, true);
                this.staffSpacing = data;
            }
            if (ch.name.toString == "page-number") {
                auto data = getString(ch, true);
                this.pageNumber = data;
            }
        }
    }
}

/**
 * The print element contains general printing parameters,
 * including the layout elements defined in the layout.mod
 * file. The part-name-display and part-abbreviation-display
 * elements used in the score.mod file may also be used here
 * to change how a part name or abbreviation is displayed over
 * the course of a piece. They take effect when the current
 * measure or a succeeding measure starts a new system.
 * 
 * The new-system and new-page attributes indicate whether
 * to force a system or page break, or to force the current
 * music onto the same system or page as the preceding music.
 * Normally this is the first music data within a measure.
 * If used in multi-part music, they should be placed in the
 * same positions within each part, or the results are
 * undefined. The page-number attribute sets the number of a
 * new page; it is ignored if new-page is not "yes". Version
 * 2.0 adds a blank-page attribute. This is a positive integer
 * value that specifies the number of blank pages to insert
 * before the current measure. It is ignored if new-page is
 * not "yes". These blank pages have no music, but may have
 * text or images specified by the credit element. This is
 * used to allow a combination of pages that are all text,
 * or all text and images, together with pages of music.
 * 
 * Staff spacing between multiple staves is measured in
 * tenths of staff lines (e.g. 100 = 10 staff lines). This is
 * deprecated as of Version 1.1; the staff-layout element
 * should be used instead. If both are present, the
 * staff-layout values take priority.
 * 
 * Layout elements in a print statement only apply to the
 * current page, system, staff, or measure. Music that
 * follows continues to take the default values from the
 * layout included in the defaults element.
 */
mixin template IPrint() {
    MeasureNumbering measureNumbering;
    PartNameDisplay partNameDisplay;
    bool newSystem;
    bool newPage;
    string blankPage;
    MeasureLayout measureLayout;
    PartAbbreviationDisplay partAbbreviationDisplay;
    PageLayout pageLayout;
    SystemLayout systemLayout;
    float staffSpacing;
    StaffLayout[] staffLayouts;
    string pageNumber;
}

/**
 * The measure-numbering element describes how measure
 * numbers are displayed on this part. Values may be none,
 * measure, or system. The number attribute from the measure
 * element is used for printing. Measures with an implicit
 * attribute set to "yes" never display a measure number,
 * regardless of the measure-numbering setting.
 */
export class MeasureNumbering {
    mixin IMeasureNumbering;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
    }
}

/**
 * The measure-numbering element describes how measure
 * numbers are displayed on this part. Values may be none,
 * measure, or system. The number attribute from the measure
 * element is used for printing. Measures with an implicit
 * attribute set to "yes" never display a measure number,
 * regardless of the measure-numbering setting.
 */
mixin template IMeasureNumbering() {
    mixin IPrintStyleAlign;
    string data;
}

/**
 * The sound element contains general playback parameters.
 * They can stand alone within a part/measure, or be a
 * component element within a direction.
 * 
 * Tempo is expressed in quarter notes per minute. If 0,
 * the sound-generating program should prompt the user at the
 * time of compiling a sound (MIDI) file.
 * 
 * Dynamics (or MIDI velocity) are expressed as a percentage
 * of the default forte value (90 for MIDI 1.0).
 * 
 * Dacapo indicates to go back to the beginning of the
 * movement. When used it always has the value "yes".
 * 
 * Segno and dalsegno are used for backwards jumps to a
 * segno sign; coda and tocoda are used for forward jumps
 * to a coda sign. If there are multiple jumps, the value
 * of these parameters can be used to name and distinguish
 * them. If segno or coda is used, the divisions attribute
 * can also be used to indicate the number of divisions
 * per quarter note. Otherwise sound and MIDI generating
 * programs may have to recompute this.
 * 
 * By default, a dalsegno or dacapo attribute indicates that
 * the jump should occur the first time through, while a
 * tocoda attribute indicates the jump should occur the second
 * time through. The time that jumps occur can be changed by
 * using the time-only attribute.
 * 
 * Forward-repeat is used when a forward repeat sign is
 * implied, and usually follows a bar line. When used it
 * always has the value of "yes".
 * 
 * The fine attribute follows the final note or rest in a
 * movement with a da capo or dal segno direction. If numeric,
 * the value represents the actual duration of the final note or
 * rest, which can be ambiguous in written notation and
 * different among parts and voices. The value may also be
 * "yes" to indicate no change to the final duration.
 * 
 * If the sound element applies only particular times through a
 * repeat, the time-only attribute indicates which times to apply
 * the sound element. The value is a comma-separated list of
 * positive integers arranged in ascending order, indicating
 * which times through the repeated section that the element
 * applies.
 * 
 * Pizzicato in a sound element effects all following notes.
 * Yes indicates pizzicato, no indicates arco.
 * 
 * The pan and elevation attributes are deprecated in
 * Version 2.0. The pan and elevation elements in
 * the midi-instrument element should be used instead.
 * The meaning of the pan and elevation attributes is
 * the same as for the pan and elevation elements. If
 * both are present, the mid-instrument elements take
 * priority.
 * 
 * The damper-pedal, soft-pedal, and sostenuto-pedal
 * attributes effect playback of the three common piano
 * pedals and their MIDI controller equivalents. The yes
 * value indicates the pedal is depressed; no indicates
 * the pedal is released. A numeric value from 0 to 100
 * may also be used for half pedaling. This value is the
 * percentage that the pedal is depressed. A value of 0 is
 * equivalent to no, and a value of 100 is equivalent to yes.
 * 
 * MIDI devices, MIDI instruments, and playback techniques are
 * changed using the midi-device, midi-instrument, and play
 * elements defined in the common.mod file. When there are
 * multiple instances of these elements, they should be grouped
 * together by instrument using the id attribute values.
 * 
 * The offset element is used to indicate that the sound takes
 * place offset from the current score position. If the sound
 * element is a child of a direction element, the sound offset
 * element overrides the direction offset element if both
 * elements are present. Note that the offset reflects the
 * intended musical position for the change in sound. It
 * should not be used to compensate for latency issues in
 * particular hardware configurations.
 */
export class Sound {
    mixin ISound;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "midi-instrument") {
                auto data = new MidiInstrument(ch) ;
                this.midiInstrument = data;
            }
            if (ch.name.toString == "play") {
                auto data = new Play(ch) ;
                this.plays ~= data;
            }
            if (ch.name.toString == "offset") {
                auto data = new Offset(ch) ;
                this.offset = data;
            }
            if (ch.name.toString == "midi-device") {
                auto data = new MidiDevice(ch) ;
                this.midiDevice = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "soft-pedal") {
                auto data = getYesNo(ch, true);
                this.softPedal = data;
            }
            if (ch.name.toString == "pan") {
                auto data = getString(ch, true);
                this.pan = data;
            }
            if (ch.name.toString == "tocoda") {
                auto data = getString(ch, true);
                this.tocoda = data;
            }
            if (ch.name.toString == "decapo") {
                auto data = getYesNo(ch, true);
                this.decapo = data;
            }
            if (ch.name.toString == "divisions") {
                auto data = getString(ch, true);
                this.divisions = data;
            }
            if (ch.name.toString == "pizzicato") {
                auto data = getYesNo(ch, true);
                this.pizzicato = data;
            }
            if (ch.name.toString == "coda") {
                auto data = getString(ch, true);
                this.coda = data;
            }
            if (ch.name.toString == "segno") {
                auto data = getString(ch, true);
                this.segno = data;
            }
            if (ch.name.toString == "elevation") {
                auto data = getString(ch, true);
                this.elevation = data;
            }
            if (ch.name.toString == "fine") {
                auto data = getString(ch, true);
                this.fine = data;
            }
            if (ch.name.toString == "damper-pedal") {
                auto data = getYesNo(ch, true);
                this.damperPedal = data;
            }
            if (ch.name.toString == "dynamics") {
                auto data = getString(ch, true);
                this.dynamics = data;
            }
            if (ch.name.toString == "time-only") {
                auto data = getString(ch, true);
                this.timeOnly = data;
            }
            if (ch.name.toString == "sostenuto-pedal") {
                auto data = getYesNo(ch, true);
                this.sostenutoPedal = data;
            }
            if (ch.name.toString == "dalsegno") {
                auto data = getString(ch, true);
                this.dalsegno = data;
            }
            if (ch.name.toString == "tempo") {
                auto data = getString(ch, true);
                this.tempo = data;
            }
            if (ch.name.toString == "forward-repeat") {
                auto data = getYesNo(ch, true);
                this.forwardRepeat = data;
            }
        }
    }
}

/**
 * The sound element contains general playback parameters.
 * They can stand alone within a part/measure, or be a
 * component element within a direction.
 * 
 * Tempo is expressed in quarter notes per minute. If 0,
 * the sound-generating program should prompt the user at the
 * time of compiling a sound (MIDI) file.
 * 
 * Dynamics (or MIDI velocity) are expressed as a percentage
 * of the default forte value (90 for MIDI 1.0).
 * 
 * Dacapo indicates to go back to the beginning of the
 * movement. When used it always has the value "yes".
 * 
 * Segno and dalsegno are used for backwards jumps to a
 * segno sign; coda and tocoda are used for forward jumps
 * to a coda sign. If there are multiple jumps, the value
 * of these parameters can be used to name and distinguish
 * them. If segno or coda is used, the divisions attribute
 * can also be used to indicate the number of divisions
 * per quarter note. Otherwise sound and MIDI generating
 * programs may have to recompute this.
 * 
 * By default, a dalsegno or dacapo attribute indicates that
 * the jump should occur the first time through, while a
 * tocoda attribute indicates the jump should occur the second
 * time through. The time that jumps occur can be changed by
 * using the time-only attribute.
 * 
 * Forward-repeat is used when a forward repeat sign is
 * implied, and usually follows a bar line. When used it
 * always has the value of "yes".
 * 
 * The fine attribute follows the final note or rest in a
 * movement with a da capo or dal segno direction. If numeric,
 * the value represents the actual duration of the final note or
 * rest, which can be ambiguous in written notation and
 * different among parts and voices. The value may also be
 * "yes" to indicate no change to the final duration.
 * 
 * If the sound element applies only particular times through a
 * repeat, the time-only attribute indicates which times to apply
 * the sound element. The value is a comma-separated list of
 * positive integers arranged in ascending order, indicating
 * which times through the repeated section that the element
 * applies.
 * 
 * Pizzicato in a sound element effects all following notes.
 * Yes indicates pizzicato, no indicates arco.
 * 
 * The pan and elevation attributes are deprecated in
 * Version 2.0. The pan and elevation elements in
 * the midi-instrument element should be used instead.
 * The meaning of the pan and elevation attributes is
 * the same as for the pan and elevation elements. If
 * both are present, the mid-instrument elements take
 * priority.
 * 
 * The damper-pedal, soft-pedal, and sostenuto-pedal
 * attributes effect playback of the three common piano
 * pedals and their MIDI controller equivalents. The yes
 * value indicates the pedal is depressed; no indicates
 * the pedal is released. A numeric value from 0 to 100
 * may also be used for half pedaling. This value is the
 * percentage that the pedal is depressed. A value of 0 is
 * equivalent to no, and a value of 100 is equivalent to yes.
 * 
 * MIDI devices, MIDI instruments, and playback techniques are
 * changed using the midi-device, midi-instrument, and play
 * elements defined in the common.mod file. When there are
 * multiple instances of these elements, they should be grouped
 * together by instrument using the id attribute values.
 * 
 * The offset element is used to indicate that the sound takes
 * place offset from the current score position. If the sound
 * element is a child of a direction element, the sound offset
 * element overrides the direction offset element if both
 * elements are present. Note that the offset reflects the
 * intended musical position for the change in sound. It
 * should not be used to compensate for latency issues in
 * particular hardware configurations.
 */
mixin template ISound() {
    mixin ITimeOnly;
    bool softPedal;
    MidiInstrument midiInstrument;
    string pan;
    string tocoda;
    bool decapo;
    string divisions;
    bool pizzicato;
    string coda;
    string segno;
    string elevation;
    string fine;
    bool damperPedal;
    string dynamics;
    Play[] plays;
    Offset offset;
    bool sostenutoPedal;
    string dalsegno;
    MidiDevice midiDevice;
    string tempo;
    bool forwardRepeat;
}

/**
 * Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */
export class Work {
    mixin IWork;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "work-number") {
                auto data = getString(ch, true);
                this.workNumber = data;
            }
            if (ch.name.toString == "work-title") {
                auto data = getString(ch, true);
                this.workTitle = data;
            }
            if (ch.name.toString == "opus") {
                auto data = new Opus(ch) ;
                this.opus = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Works and movements are optionally identified by number
 * and title. The work element also may indicate a link
 * to the opus document that composes multiple movements
 * into a collection.
 */
mixin template IWork() {
    string workNumber;
    string workTitle;
    Opus opus;
}

/**
 * Ripieno MusicXML does not support this field.
 */
export class Opus {
    mixin IOpus;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Ripieno MusicXML does not support this field.
 */
mixin template IOpus() {
}

/**
 * Collect score-wide defaults. This includes scaling
 * and layout, defined in layout.mod, and default values
 * for the music font, word font, lyric font, and
 * lyric language. The number and name attributes in
 * lyric-font and lyric-language elements are typically
 * used when lyrics are provided in multiple languages.
 * If the number and name attributes are omitted, the
 * lyric-font and lyric-language values apply to all
 * numbers and names.
 */
export class Defaults {
    mixin IDefaults;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "word-font") {
                auto data = new WordFont(ch) ;
                this.wordFont = data;
            }
            if (ch.name.toString == "lyric-language") {
                auto data = new LyricLanguage(ch) ;
                this.lyricLanguages ~= data;
            }
            if (ch.name.toString == "lyric-font") {
                auto data = new LyricFont(ch) ;
                this.lyricFonts ~= data;
            }
            if (ch.name.toString == "page-layout") {
                auto data = new PageLayout(ch) ;
                this.pageLayout = data;
            }
            if (ch.name.toString == "system-layout") {
                auto data = new SystemLayout(ch) ;
                this.systemLayout = data;
            }
            if (ch.name.toString == "appearance") {
                auto data = new Appearance(ch) ;
                this.appearance = data;
            }
            if (ch.name.toString == "scaling") {
                auto data = new Scaling(ch) ;
                this.scaling = data;
            }
            if (ch.name.toString == "staff-layout") {
                auto data = new StaffLayout(ch) ;
                this.staffLayouts ~= data;
            }
            if (ch.name.toString == "music-font") {
                auto data = new MusicFont(ch) ;
                this.musicFont = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * Collect score-wide defaults. This includes scaling
 * and layout, defined in layout.mod, and default values
 * for the music font, word font, lyric font, and
 * lyric language. The number and name attributes in
 * lyric-font and lyric-language elements are typically
 * used when lyrics are provided in multiple languages.
 * If the number and name attributes are omitted, the
 * lyric-font and lyric-language values apply to all
 * numbers and names.
 */
mixin template IDefaults() {
    WordFont wordFont;
    LyricLanguage[] lyricLanguages;
    LyricFont[] lyricFonts;
    PageLayout pageLayout;
    SystemLayout systemLayout;
    Appearance appearance;
    Scaling scaling;
    StaffLayout[] staffLayouts;
    MusicFont musicFont;
}

export class MusicFont {
    mixin IMusicFont;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
    }
}

mixin template IMusicFont() {
    mixin IFont;
}

export class WordFont {
    mixin IWordFont;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
    }
}

mixin template IWordFont() {
    mixin IFont;
}

export class LyricFont {
    mixin ILyricFont;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "name") {
                auto data = getString(ch, true);
                this.name = data;
            }
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
    }
}

mixin template ILyricFont() {
    mixin IFont;
    float number_;
    string name;
}

export class LyricLanguage {
    mixin ILyricLanguage;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
            }
            if (ch.name.toString == "name") {
                auto data = getString(ch, true);
                this.name = data;
            }
        }
    }
}

mixin template ILyricLanguage() {
    float number_;
    string name;
}

/**
 *     Credit elements refer to the title, composer, arranger,
 * lyricist, copyright, dedication, and other text that usually
 * appears on the first page of a score. The credit-words
 * and credit-image elements are similar to the words and
 * image elements for directions. However, since the
 * credit is not part of a measure, the default-x and
 * default-y attributes adjust the origin relative to the
 * bottom left-hand corner of the first page. The
 * enclosure for credit-words is none by default.
 * 
 * By default, a series of credit-words elements within a
 * single credit element follow one another in sequence
 * visually. Non-positional formatting attributes are carried
 * over from the previous element by default.
 * 
 * The page attribute for the credit element, new in Version
 * 2.0, specifies the page number where the credit should
 * appear. This is an integer value that starts with 1 for the
 * first page. Its value is 1 by default. Since credits occur
 * before the music, these page numbers do not refer to the
 * page numbering specified by the print element's page-number
 * attribute.
 */
export class Credit {
    mixin ICredit;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "credit-type") {
                auto data = getString(ch, true);
                this.creditTypes ~= data;
            }
            if (ch.name.toString == "credit-words") {
                auto data = new CreditWords(ch) ;
                this.creditWords ~= data;
            }
            if (ch.name.toString == "credit-image") {
                auto data = new CreditImage(ch) ;
                this.creditImage = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "page") {
                auto data = getNumber(ch, true);
                this.page = data;
            }
        }
    }
}

/**
 *     Credit elements refer to the title, composer, arranger,
 * lyricist, copyright, dedication, and other text that usually
 * appears on the first page of a score. The credit-words
 * and credit-image elements are similar to the words and
 * image elements for directions. However, since the
 * credit is not part of a measure, the default-x and
 * default-y attributes adjust the origin relative to the
 * bottom left-hand corner of the first page. The
 * enclosure for credit-words is none by default.
 * 
 * By default, a series of credit-words elements within a
 * single credit element follow one another in sequence
 * visually. Non-positional formatting attributes are carried
 * over from the previous element by default.
 * 
 * The page attribute for the credit element, new in Version
 * 2.0, specifies the page number where the credit should
 * appear. This is an integer value that starts with 1 for the
 * first page. Its value is 1 by default. Since credits occur
 * before the music, these page numbers do not refer to the
 * page numbering specified by the print element's page-number
 * attribute.
 */
mixin template ICredit() {
    string[] creditTypes;
    CreditWords[] creditWords;
    CreditImage creditImage;
    float page;
}

export class CreditWords {
    mixin ICreditWords;
    this(xmlNodePtr node) {
        bool foundJustify = false;
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundHalign = false;
        bool foundValign = false;
        bool foundUnderline = false;
        bool foundOverline = false;
        bool foundLineThrough = false;
        bool foundRotation = false;
        bool foundLetterSpacing = false;
        bool foundLineHeight = false;
        bool foundDir = false;
        bool foundEnclosure = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valign = data;
                foundValign = true;
            }
            if (ch.name.toString == "underline") {
                auto data = getNumber(ch, true);
                this.underline = data;
                foundUnderline = true;
            }
            if (ch.name.toString == "overline") {
                auto data = getNumber(ch, true);
                this.overline = data;
                foundOverline = true;
            }
            if (ch.name.toString == "line-through") {
                auto data = getNumber(ch, true);
                this.lineThrough = data;
                foundLineThrough = true;
            }
            if (ch.name.toString == "rotation") {
                auto data = getNumber(ch, true);
                this.rotation = data;
                foundRotation = true;
            }
            if (ch.name.toString == "letter-spacing") {
                auto data = getString(ch, true);
                this.letterSpacing = data;
                foundLetterSpacing = true;
            }
            if (ch.name.toString == "line-height") {
                auto data = getString(ch, true);
                this.lineHeight = data;
                foundLineHeight = true;
            }
            if (ch.name.toString == "dir") {
                auto data = getDirectionMode(ch);
                this.dir = data;
                foundDir = true;
            }
            if (ch.name.toString == "enclosure") {
                auto data = getEnclosureShape(ch);
                this.enclosure = data;
                foundEnclosure = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.words = data;
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValign) {
            valign = TopMiddleBottomBaseline.Bottom;
        }
        if (!foundUnderline) {
            underline = 0;
        }
        if (!foundOverline) {
            overline = 0;
        }
        if (!foundLineThrough) {
            lineThrough = 0;
        }
        if (!foundRotation) {
            rotation = 0;
        }
        if (!foundLetterSpacing) {
            letterSpacing = "normal";
        }
        if (!foundLineHeight) {
            lineHeight = "normal";
        }
        if (!foundDir) {
            dir = DirectionMode.Ltr;
        }
        if (!foundEnclosure) {
            enclosure = EnclosureShape.None;
        }
    }
}

mixin template ICreditWords() {
    mixin ITextFormatting;
    string words;
}

export class CreditImage {
    mixin ICreditImage;
    this(xmlNodePtr node) {
        bool foundHalign = false;
        bool foundValignImage = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "halign") {
                auto data = getLeftCenterRight(ch);
                this.halign = data;
                foundHalign = true;
            }
            if (ch.name.toString == "valign-image") {
                auto data = getTopMiddleBottomBaseline(ch);
                this.valignImage = data;
                foundValignImage = true;
            }
            if (ch.name.toString == "type") {
                auto data = getString(ch, true);
                this.type = data;
            }
            if (ch.name.toString == "source") {
                auto data = getString(ch, true);
                this.source = data;
            }
        }
        if (!foundHalign) {
            halign = delegate () { static if (__traits(compiles, justify)) return justify; else return LeftCenterRight.Left; }();
        }
        if (!foundValignImage) {
            valignImage = TopMiddleBottomBaseline.Bottom;
        }
    }
}

mixin template ICreditImage() {
    mixin IPosition;
    mixin IHalign;
    mixin IValignImage;
    string type;
    string source;
}

/**
 * The part-list identifies the different musical parts in
 * this movement. Each part has an ID that is used later
 * within the musical data. Since parts may be encoded
 * separately and combined later, identification elements
 * are present at both the score and score-part levels.
 * There must be at least one score-part, combined as
 * desired with part-group elements that indicate braces
 * and brackets. Parts are ordered from top to bottom in
 * a score based on the order in which they appear in the
 * part-list.
 * 
 * Each MusicXML part corresponds to a track in a Standard
 * MIDI Format 1 file. The score-instrument elements are
 * used when there are multiple instruments per track.
 * The midi-device element is used to make a MIDI device
 * or port assignment for the given track or specific MIDI
 * instruments. Initial midi-instrument assignments may be
 * made here as well.
 */
export class PartList {
    mixin IPartList;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "score-part") {
                auto data = new ScorePart(ch) ;
                this.scoreParts ~= data;
            }
            if (ch.name.toString == "part-group") {
                auto data = new PartGroup(ch) ;
                this.partGroups ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The part-list identifies the different musical parts in
 * this movement. Each part has an ID that is used later
 * within the musical data. Since parts may be encoded
 * separately and combined later, identification elements
 * are present at both the score and score-part levels.
 * There must be at least one score-part, combined as
 * desired with part-group elements that indicate braces
 * and brackets. Parts are ordered from top to bottom in
 * a score based on the order in which they appear in the
 * part-list.
 * 
 * Each MusicXML part corresponds to a track in a Standard
 * MIDI Format 1 file. The score-instrument elements are
 * used when there are multiple instruments per track.
 * The midi-device element is used to make a MIDI device
 * or port assignment for the given track or specific MIDI
 * instruments. Initial midi-instrument assignments may be
 * made here as well.
 */
mixin template IPartList() {
    ScorePart[] scoreParts;
    PartGroup[] partGroups;
}

export class ScorePart {
    mixin IScorePart;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "identification") {
                auto data = new Identification(ch) ;
                this.identification = data;
            }
            if (ch.name.toString == "part-name-display") {
                auto data = new PartNameDisplay(ch) ;
                this.partNameDisplay = data;
            }
            if (ch.name.toString == "score-instrument") {
                auto data = new ScoreInstrument(ch) ;
                this.scoreInstruments ~= data;
            }
            if (ch.name.toString == "midi-device") {
                auto data = new MidiDevice(ch) ;
                this.midiDevices ~= data;
            }
            if (ch.name.toString == "part-name") {
                auto data = new PartName(ch) ;
                this.partName = data;
            }
            if (ch.name.toString == "part-abbreviation-display") {
                auto data = new PartAbbreviationDisplay(ch) ;
                this.partAbbreviationDisplay = data;
            }
            if (ch.name.toString == "part-abbreviation") {
                auto data = new PartAbbreviation(ch) ;
                this.partAbbreviation = data;
            }
            if (ch.name.toString == "group") {
                auto data = getString(ch, true);
                this.groups ~= data;
            }
            if (ch.name.toString == "midi-instrument") {
                auto data = new MidiInstrument(ch) ;
                this.midiInstruments ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "id") {
                auto data = getString(ch, true);
                this.id = data;
            }
        }
    }
}

mixin template IScorePart() {
    Identification identification;
    PartNameDisplay partNameDisplay;
    ScoreInstrument[] scoreInstruments;
    MidiDevice[] midiDevices;
    PartName partName;
    PartAbbreviationDisplay partAbbreviationDisplay;
    PartAbbreviation partAbbreviation;
    string[] groups;
    MidiInstrument[] midiInstruments;
    string id;
}

/**
 *     The part-name indicates the full name of the musical part.
 * The part-abbreviation indicates the abbreviated version of
 * the name of the musical part. The part-name will often
 * precede the first system, while the part-abbreviation will
 * precede the other systems. The formatting attributes for
 * these elements are deprecated in Version 2.0 in favor of
 * the new part-name-display and part-abbreviation-display
 * elements. These are defined in the common.mod file as they
 * are used in both the part-list and print elements. They
 * provide more complete formatting control for how part names
 * and abbreviations appear in a score.
 */
export class PartName {
    mixin IPartName;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.partName = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 *     The part-name indicates the full name of the musical part.
 * The part-abbreviation indicates the abbreviated version of
 * the name of the musical part. The part-name will often
 * precede the first system, while the part-abbreviation will
 * precede the other systems. The formatting attributes for
 * these elements are deprecated in Version 2.0 in favor of
 * the new part-name-display and part-abbreviation-display
 * elements. These are defined in the common.mod file as they
 * are used in both the part-list and print elements. They
 * provide more complete formatting control for how part names
 * and abbreviations appear in a score.
 */
mixin template IPartName() {
    mixin IPrintStyle;
    mixin IPrintObject;
    mixin IJustify;
    string partName;
}

/**
 *     The part-name indicates the full name of the musical part.
 * The part-abbreviation indicates the abbreviated version of
 * the name of the musical part. The part-name will often
 * precede the first system, while the part-abbreviation will
 * precede the other systems. The formatting attributes for
 * these elements are deprecated in Version 2.0 in favor of
 * the new part-name-display and part-abbreviation-display
 * elements. These are defined in the common.mod file as they
 * are used in both the part-list and print elements. They
 * provide more complete formatting control for how part names
 * and abbreviations appear in a score.
 */
export class PartAbbreviation {
    mixin IPartAbbreviation;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundPrintObject = false;
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.abbreviation = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundPrintObject) {
            printObject = true;
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 *     The part-name indicates the full name of the musical part.
 * The part-abbreviation indicates the abbreviated version of
 * the name of the musical part. The part-name will often
 * precede the first system, while the part-abbreviation will
 * precede the other systems. The formatting attributes for
 * these elements are deprecated in Version 2.0 in favor of
 * the new part-name-display and part-abbreviation-display
 * elements. These are defined in the common.mod file as they
 * are used in both the part-list and print elements. They
 * provide more complete formatting control for how part names
 * and abbreviations appear in a score.
 */
mixin template IPartAbbreviation() {
    mixin IPrintStyle;
    mixin IPrintObject;
    mixin IJustify;
    string abbreviation;
}

/**
 * The part-group element indicates groupings of parts in the
 * score, usually indicated by braces and brackets. Braces
 * that are used for multi-staff parts should be defined in
 * the attributes element for that part.
 * 
 * A part-group element is not needed for a single multi-staff
 * part. By default, multi-staff parts include a brace symbol
 * and (if appropriate given the bar-style) common barlines.
 * The symbol formatting for a multi-staff part can be more
 * fully specified using the part-symbol element.
 */
export class PartGroup {
    mixin IPartGroup;
    this(xmlNodePtr node) {
        bool foundNumber_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "group-name-display") {
                auto data = new GroupNameDisplay(ch) ;
                this.groupNameDisplay = data;
            }
            if (ch.name.toString == "group-symbol") {
                auto data = new GroupSymbol(ch) ;
                this.groupSymbol = data;
            }
            if (ch.name.toString == "group-name") {
                auto data = new GroupName(ch) ;
                this.groupName = data;
            }
            if (ch.name.toString == "group-abbreviation-display") {
                auto data = new GroupAbbreviationDisplay(ch) ;
                this.groupAbbreviationDisplay = data;
            }
            if (ch.name.toString == "group-barline") {
                auto data = new GroupBarline(ch) ;
                this.groupBarline = data;
            }
            if (ch.name.toString == "footnote") {
                auto data = new Footnote(ch) ;
                this.footnote = data;
            }
            if (ch.name.toString == "level") {
                auto data = new Level(ch) ;
                this.level = data;
            }
            if (ch.name.toString == "group-abbreviation") {
                auto data = new GroupAbbreviation(ch) ;
                this.groupAbbreviation = data;
            }
            if (ch.name.toString == "group-time") {
                auto data = new GroupTime(ch) ;
                this.groupTime = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "number") {
                auto data = getNumber(ch, true);
                this.number_ = data;
                foundNumber_ = true;
            }
            if (ch.name.toString == "type") {
                auto data = getStartStop(ch);
                this.type = data;
            }
        }
        if (!foundNumber_) {
            number_ = 1;
        }
    }
}

/**
 * The part-group element indicates groupings of parts in the
 * score, usually indicated by braces and brackets. Braces
 * that are used for multi-staff parts should be defined in
 * the attributes element for that part.
 * 
 * A part-group element is not needed for a single multi-staff
 * part. By default, multi-staff parts include a brace symbol
 * and (if appropriate given the bar-style) common barlines.
 * The symbol formatting for a multi-staff part can be more
 * fully specified using the part-symbol element.
 */
mixin template IPartGroup() {
    mixin IEditorial;
    GroupNameDisplay groupNameDisplay;
    GroupSymbol groupSymbol;
    GroupName groupName;
    GroupAbbreviationDisplay groupAbbreviationDisplay;
    GroupBarline groupBarline;
    float number_;
    GroupAbbreviation groupAbbreviation;
    StartStop type;
    GroupTime groupTime;
}

/**
 * As with parts, groups can have a name and abbreviation.
 * Formatting attributes for group-name and group-abbreviation
 * are deprecated in Version 2.0 in favor of the new
 * group-name-display and group-abbreviation-display elements.
 */
export class GroupName {
    mixin IGroupName;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.name = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 * As with parts, groups can have a name and abbreviation.
 * Formatting attributes for group-name and group-abbreviation
 * are deprecated in Version 2.0 in favor of the new
 * group-name-display and group-abbreviation-display elements.
 */
mixin template IGroupName() {
    mixin IPrintStyle;
    mixin IJustify;
    string name;
}

/**
 * Formatting specified in the group-name-display and
 * group-abbreviation-display elements overrides formatting
 * specified in the group-name and group-abbreviation
 * elements, respectively.
 */
export class GroupNameDisplay {
    mixin IGroupNameDisplay;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "display-text") {
                auto data = new DisplayText(ch) ;
                this.displayTexts ~= data;
            }
            if (ch.name.toString == "accidental-text") {
                auto data = new AccidentalText(ch) ;
                this.accidentalTexts ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * Formatting specified in the group-name-display and
 * group-abbreviation-display elements overrides formatting
 * specified in the group-name and group-abbreviation
 * elements, respectively.
 */
mixin template IGroupNameDisplay() {
    mixin IPrintObject;
    DisplayText[] displayTexts;
    AccidentalText[] accidentalTexts;
}

/**
 * As with parts, groups can have a name and abbreviation.
 * Formatting attributes for group-name and group-abbreviation
 * are deprecated in Version 2.0 in favor of the new
 * group-name-display and group-abbreviation-display elements.
 */
export class GroupAbbreviation {
    mixin IGroupAbbreviation;
    this(xmlNodePtr node) {
        bool foundFontWeight = false;
        bool foundFontStyle = false;
        bool foundColor = false;
        bool foundJustify = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "font-family") {
                auto data = getString(ch, true);
                this.fontFamily = data;
            }
            if (ch.name.toString == "font-weight") {
                auto data = getNormalBold(ch);
                this.fontWeight = data;
                foundFontWeight = true;
            }
            if (ch.name.toString == "font-style") {
                auto data = getNormalItalic(ch);
                this.fontStyle = data;
                foundFontStyle = true;
            }
            if (ch.name.toString == "font-size") {
                auto data = getString(ch, true);
                this.fontSize = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
            if (ch.name.toString == "justify") {
                auto data = getLeftCenterRight(ch);
                this.justify = data;
                foundJustify = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.text = data;
        if (!foundFontWeight) {
            fontWeight = NormalBold.Normal;
        }
        if (!foundFontStyle) {
            fontStyle = NormalItalic.Normal;
        }
        if (!foundColor) {
            color = "#000000";
        }
        if (!foundJustify) {
            justify = LeftCenterRight.Left;
        }
    }
}

/**
 * As with parts, groups can have a name and abbreviation.
 * Formatting attributes for group-name and group-abbreviation
 * are deprecated in Version 2.0 in favor of the new
 * group-name-display and group-abbreviation-display elements.
 */
mixin template IGroupAbbreviation() {
    mixin IPrintStyle;
    mixin IJustify;
    string text;
}

/**
 * Formatting specified in the group-name-display and
 * group-abbreviation-display elements overrides formatting
 * specified in the group-name and group-abbreviation
 * elements, respectively.
 */
export class GroupAbbreviationDisplay {
    mixin IGroupAbbreviationDisplay;
    this(xmlNodePtr node) {
        bool foundPrintObject = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "display-text") {
                auto data = new DisplayText(ch) ;
                this.displayTexts ~= data;
            }
            if (ch.name.toString == "accidental-text") {
                auto data = new AccidentalText(ch) ;
                this.accidentalTexts ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "print-object") {
                auto data = getYesNo(ch, true);
                this.printObject = data;
                foundPrintObject = true;
            }
        }
        if (!foundPrintObject) {
            printObject = true;
        }
    }
}

/**
 * Formatting specified in the group-name-display and
 * group-abbreviation-display elements overrides formatting
 * specified in the group-name and group-abbreviation
 * elements, respectively.
 */
mixin template IGroupAbbreviationDisplay() {
    mixin IPrintObject;
    DisplayText[] displayTexts;
    AccidentalText[] accidentalTexts;
}

/**
 * The group-symbol element indicates how the symbol for
 * a group is indicated in the score. Values include none,
 * brace, line, bracket, and square; the default is none.
 */
export class GroupSymbol {
    mixin IGroupSymbol;
    this(xmlNodePtr node) {
        bool foundData = false;
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "default-x") {
                auto data = getNumber(ch, true);
                this.defaultX = data;
            }
            if (ch.name.toString == "relative-y") {
                auto data = getNumber(ch, true);
                this.relativeY = data;
            }
            if (ch.name.toString == "default-y") {
                auto data = getNumber(ch, true);
                this.defaultY = data;
            }
            if (ch.name.toString == "relative-x") {
                auto data = getNumber(ch, true);
                this.relativeX = data;
            }
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getPartSymbolType(ch);
        this.data = data;
        if (!foundData) {
            data = PartSymbolType.None;
        }
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The group-symbol element indicates how the symbol for
 * a group is indicated in the score. Values include none,
 * brace, line, bracket, and square; the default is none.
 */
mixin template IGroupSymbol() {
    mixin IPosition;
    mixin IColor;
    PartSymbolType data;
}

/**
 * The group-barline element indicates if the group should
 * have common barlines. Values can be yes, no, or
 * Mensurstrich. 
 */
export class GroupBarline {
    mixin IGroupBarline;
    this(xmlNodePtr node) {
        bool foundColor = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "color") {
                auto data = getString(ch, true);
                this.color = data;
                foundColor = true;
            }
        }
        auto ch = node;
        auto data = getString(ch, true);
        this.data = data;
        if (!foundColor) {
            color = "#000000";
        }
    }
}

/**
 * The group-barline element indicates if the group should
 * have common barlines. Values can be yes, no, or
 * Mensurstrich. 
 */
mixin template IGroupBarline() {
    mixin IColor;
    string data;
}

/**
 * The group-time element indicates that the
 * displayed time signatures should stretch across all parts
 * and staves in the group.
 */
export class GroupTime {
    mixin IGroupTime;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The group-time element indicates that the
 * displayed time signatures should stretch across all parts
 * and staves in the group.
 */
mixin template IGroupTime() {
}

/**
 *     The score-instrument element allows for multiple
 * instruments per score-part. As with the score-part
 * element, each score-instrument has a required ID
 * attribute, a name, and an optional abbreviation. The
 * instrument-name and instrument-abbreviation are
 * typically used within a software application, rather
 * than appearing on the printed page of a score.
 * 
 * A score-instrument element is also required if the
 * score specifies MIDI 1.0 channels, banks, or programs.
 * An initial midi-instrument assignment can also
 * be made here.
 * 
 * The instrument-sound and virtual-instrument elements
 * are new as of Version 3.0. The instrument-sound element
 * describes the default timbre of the score-instrument. This
 * description is independent of a particular virtual or
 * MIDI instrument specification and allows playback to be
 * shared more easily between applications and libraries.
 * The virtual-instrument element defines a specific virtual
 * instrument used for an instrument sound. The
 * virtual-library element indicates the virtual instrument
 * library name, and the virtual-name element indicates the
 * library-specific name for the virtual instrument.
 * 
 * The solo and ensemble elements are new as of Version
 * 2.0. The solo element is present if performance is
 * intended by a solo instrument. The ensemble element
 * is present if performance is intended by an ensemble
 * such as an orchestral section. The text of the
 * ensemble element contains the size of the section,
 * or is empty if the ensemble size is not specified.
 * 
 * The midi-instrument element is defined in the common.mod
 * file, as it can be used within both the score-part and
 * sound elements.
 */
export class ScoreInstrument {
    mixin IScoreInstrument;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "instrument-name") {
                auto data = getString(ch, true);
                this.instrumentName = data;
            }
            if (ch.name.toString == "instrument-sound") {
                auto data = getString(ch, true);
                this.instrumentSound = data;
            }
            if (ch.name.toString == "ensemble") {
                auto data = getString(ch, true);
                this.ensemble = data;
            }
            if (ch.name.toString == "virtual-instrument") {
                auto data = new VirtualInstrument(ch) ;
                this.virtualInstrument = data;
            }
            if (ch.name.toString == "instrument-abbreviation") {
                auto data = getString(ch, true);
                this.instrumentAbbreviation = data;
            }
            if (ch.name.toString == "solo") {
                auto data = new Solo(ch) ;
                this.solo = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "id") {
                auto data = getString(ch, true);
                this.id = data;
            }
        }
    }
}

/**
 *     The score-instrument element allows for multiple
 * instruments per score-part. As with the score-part
 * element, each score-instrument has a required ID
 * attribute, a name, and an optional abbreviation. The
 * instrument-name and instrument-abbreviation are
 * typically used within a software application, rather
 * than appearing on the printed page of a score.
 * 
 * A score-instrument element is also required if the
 * score specifies MIDI 1.0 channels, banks, or programs.
 * An initial midi-instrument assignment can also
 * be made here.
 * 
 * The instrument-sound and virtual-instrument elements
 * are new as of Version 3.0. The instrument-sound element
 * describes the default timbre of the score-instrument. This
 * description is independent of a particular virtual or
 * MIDI instrument specification and allows playback to be
 * shared more easily between applications and libraries.
 * The virtual-instrument element defines a specific virtual
 * instrument used for an instrument sound. The
 * virtual-library element indicates the virtual instrument
 * library name, and the virtual-name element indicates the
 * library-specific name for the virtual instrument.
 * 
 * The solo and ensemble elements are new as of Version
 * 2.0. The solo element is present if performance is
 * intended by a solo instrument. The ensemble element
 * is present if performance is intended by an ensemble
 * such as an orchestral section. The text of the
 * ensemble element contains the size of the section,
 * or is empty if the ensemble size is not specified.
 * 
 * The midi-instrument element is defined in the common.mod
 * file, as it can be used within both the score-part and
 * sound elements.
 */
mixin template IScoreInstrument() {
    string instrumentName;
    string instrumentSound;
    string ensemble;
    VirtualInstrument virtualInstrument;
    string instrumentAbbreviation;
    Solo solo;
    string id;
}

export class Solo {
    mixin ISolo;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template ISolo() {
}

export class VirtualInstrument {
    mixin IVirtualInstrument;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "virtual-library") {
                auto data = getString(ch, true);
                this.virtualLibrary = data;
            }
            if (ch.name.toString == "virtual-name") {
                auto data = getString(ch, true);
                this.virtualName = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

mixin template IVirtualInstrument() {
    string virtualLibrary;
    string virtualName;
}

/**
 * The score-header entity contains basic score metadata
 * about the work and movement, score-wide defaults for
 * layout and fonts, credits that appear on the first page,
 * and the part list.
 */
export class ScoreHeader {
    mixin IScoreHeader;
    this(xmlNodePtr node) {
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "movement-title") {
                auto data = getString(ch, true);
                this.movementTitle = data;
            }
            if (ch.name.toString == "identification") {
                auto data = new Identification(ch) ;
                this.identification = data;
            }
            if (ch.name.toString == "defaults") {
                auto data = new Defaults(ch) ;
                this.defaults = data;
            }
            if (ch.name.toString == "work") {
                auto data = new Work(ch) ;
                this.work = data;
            }
            if (ch.name.toString == "credit") {
                auto data = new Credit(ch) ;
                this.credits ~= data;
            }
            if (ch.name.toString == "part-list") {
                auto data = new PartList(ch) ;
                this.partList = data;
            }
            if (ch.name.toString == "movement-number") {
                auto data = getString(ch, true);
                this.movementNumber = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    }
}

/**
 * The score-header entity contains basic score metadata
 * about the work and movement, score-wide defaults for
 * layout and fonts, credits that appear on the first page,
 * and the part list.
 */
mixin template IScoreHeader() {
    string movementTitle;
    Identification identification;
    Defaults defaults;
    Work work;
    Credit[] credits;
    PartList partList;
    string movementNumber;
}

/**
 * The score is the root element for the DTD. It includes
 * the score-header entity, followed by a series of
 * measures with parts inside.
 * 
 * See also score-partwise.
 */
export class ScoreTimewise {
    mixin IScoreTimewise;
    this(xmlNodePtr node) {
        bool foundVersion_ = false;
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "measure") {
                auto data = new Measure(ch) ;
                this.measures ~= data;
            }
            if (ch.name.toString == "movement-title") {
                auto data = getString(ch, true);
                this.movementTitle = data;
            }
            if (ch.name.toString == "identification") {
                auto data = new Identification(ch) ;
                this.identification = data;
            }
            if (ch.name.toString == "defaults") {
                auto data = new Defaults(ch) ;
                this.defaults = data;
            }
            if (ch.name.toString == "work") {
                auto data = new Work(ch) ;
                this.work = data;
            }
            if (ch.name.toString == "credit") {
                auto data = new Credit(ch) ;
                this.credits ~= data;
            }
            if (ch.name.toString == "part-list") {
                auto data = new PartList(ch) ;
                this.partList = data;
            }
            if (ch.name.toString == "movement-number") {
                auto data = getString(ch, true);
                this.movementNumber = data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
            if (ch.name.toString == "version") {
                auto data = getString(ch, true);
                this.version_ = data;
                foundVersion_ = true;
            }
        }
        if (!foundVersion_) {
            version_ = "1.0";
        }
    }
}

/**
 * The score is the root element for the DTD. It includes
 * the score-header entity, followed by a series of
 * measures with parts inside.
 * 
 * See also score-partwise.
 */
mixin template IScoreTimewise() {
    mixin IDocumentAttributes;
    mixin IScoreHeader;
    Measure[] measures;
}

/**
 * The basic musical data that is associated with a measure.
 */
Variant[] Part(xmlNodePtr node) {
    Variant[] rarr = [];
        for (auto ch = node.children.firstElement; ch; ch = ch.nextElement) {
            if (ch.name.toString == "note") {
                auto data = Variant(new Note(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "backup") {
                auto data = Variant(new Backup(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "harmony") {
                auto data = Variant(new Harmony(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "forward") {
                auto data = Variant(new Forward(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "print") {
                auto data = Variant(new Print(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "figured-bass") {
                auto data = Variant(new FiguredBass(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "direction") {
                auto data = Variant(new Direction(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "attributes") {
                auto data = Variant(new Attributes(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "sound") {
                auto data = Variant(new Sound(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "barline") {
                auto data = Variant(new Barline(ch) );
                rarr ~= data;
            }
            if (ch.name.toString == "grouping") {
                auto data = Variant(new Grouping(ch) );
                rarr ~= data;
            }
        }
        for (auto ch = node.properties; ch; ch = ch.next) {
        }
    return rarr;
}


/**
 * Represents a measure.
 */
mixin template IMeasure() {
    string number_;
    bool implicit;
    float width;
    Variant[][string] parts;
    bool nonControlling;
}

