### Notes

- We estimate the (effective) **reproduction number** *R(t)* at day *t*, i.e. the average number of people someone infected at time *t* would infect if conditions remained the same.
- The **estimator** has been taken from [(Fraser 2007)](#ref1). It compares the number of infections at a time point with the number of infectious cases at that time, weighted by their respective infectivity. Note that constant (per country) **underreporting** does not affect the estimates since both the number of infections and the number of infectious persons are reduced by the same proportionality factor.
- For this estimator, we derived (approximate, pointwise) **95% confidence intervals** using the delta method.
- However, the size of the confidence intervals reflects only those statistical uncertainties due to the random dynamics of the epidemic. But since the estimator is based on assumptions about the infectivity of the virus, and given that the data are not perfect because of a change of reporting criteria, varying amounts of testing etc., **the estimates should be interpreted cautiously** and not be taken at face value (especially when case counts are low). Still, we believe that one can draw qualitatively credible conclusions from them.
- Estimates are shown in black, confidence intervals as grey stripes, with values specified by the **left axis** (on a **log-scale**; thus 0 is always out of sight, at the infinite lower end of the axis). If estimates cannot sensibly be determined due to insufficient data, values are interpolated by dashed lines without confidence intervals.
- The **critical value** for the reproduction number is 1, shown as a red horizontal line: a value larger than one would result in an exponential increase of infections, a value smaller than one in a decrease.
- The analysis is based on **newly reported cases** of Coronavirus Disease 2019 (COVID-19) per day, shown as blue bars as specified by the **right axis** (on a linear scale). For these we rely on the [data provided by Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19).
- For the estimated reproduction number (black line, left vertical axis), the horizontal axis specifies the corresponding date of infection. For the newly reported cases (blue bars, right axis), it specifies the date the cases were reported. Mondays are marked by thin vertical lines.
- The graphics are **updated daily** (last update: !NOW! GMT), showing data up to yesterday.
- Note that cases are reported much later than the corresponding day of infection, namely after incubation time (about 5 days [(WHO 2020)](#ref2)) plus some more days necessary for testing and reporting the case to the authorities. For simplicity we assume that cases are reported 7 days after infection. Therefore, estimates for the reproduction number **lag one week behind** the reporting of new cases.
- In a population where no countermeasures have been put into place, the so-called **basic reproduction number** *R<sub>0</sub>* is believed to be given by some value between 2.4 and 4.1 [(Read et al. 2020)](#ref3). Estimates higher than that might be explained by a considerable number of **imported cases**.
-  **Details** may be found in the accompanying [Technical Report](reports/repronum/repronum.pdf)  [(Hotz et al. 2020)](#ref4); the **code** is available [here](https://github.com/Stochastik-TU-Ilmenau/COVID-19/blob/gh-pages/estimator.r).

### References

<a name="ref1">[1]</a>: Fraser, C. (2007). *Estimating Individual and Household Reproduction Numbers in an Emerging Epidemic.* PLOS ONE 2 (8), [https://doi.org/10.1371/journal.pone.0000758](https://doi.org/10.1371/journal.pone.0000758).

<a name="ref2">[2]</a> WHO (2020). Report of the WHO-China Joint Mission on Coronavirus Disease 2019 (COVID-19), [https://www.who.int/publications-detail/report-of-the-who-china-joint-mission-on-coronavirus-disease-2019-(covid-19)](https://www.who.int/publications-detail/report-of-the-who-china-joint-mission-on-coronavirus-disease-2019-(covid-19)).

<a name="ref3">[3]</a>: Read, J.M., Bridgen, J.R.E., Cummings, D.A.T., Ho, A., Jewell, C.P. (2020). *Novel coronavirus 2019-nCoV: early estimation of epidemiological parameters and epidemic predictions.* MedRxiv, Version 2, 01/28/2020, [https://doi.org/10.1101/2020.01.23.20018549](https://doi.org/10.1101/2020.01.23.20018549).

<a name="ref4">[4]</a>: Hotz, T., Glock, M., Heyder, S., Semper, S.,  Böhle, A., Krämer, A. (2020). *Monitoring the spread of COVID-19 by estimating reproduction numbers over time.* [arXiv:2004.08557](https://arxiv.org/abs/2004.08557), 18/04/2020.

<br/>
*[Imprint](impressum.html#imprint)*
