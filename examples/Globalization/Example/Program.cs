// See https://aka.ms/new-console-template for more information

using System.Collections;
using System.Globalization;

IEnumerable<RegionInfo> AllRegionInfo = 
CultureInfo.GetCultures(CultureTypes.SpecificCultures)
    .Where(culture => culture.LCID != 0x7F) // filer invariant culture
    .Select(culture => new RegionInfo(culture.Name))
    .ToList();

Console.WriteLine(string.Join(Environment.NewLine,AllRegionInfo));