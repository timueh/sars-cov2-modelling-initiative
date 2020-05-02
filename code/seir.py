import numpy as np


def stochastic(
    numScenarios: int,
    arrData0: np.ndarray,
    numProbEtoI: float,
    numProbItoR: float,
    lstArrGInd: list,
    lstArrG: list,
    path=None,
) -> np.ndarray:
    """Stochastic Simulation of a group-based SEIR Model

    Explanation

    Parameters
    ----------
    numScenarios : int
        Number of scenarios to simulate
    arrData0 : np.ndarray
        Initial values
    numProbEtoI : float
        Probability for an individual to transition from latent
        to infectious state.
    numProbItoR : float
        Probability for an individual to transition from infectious
        to recovered state.
    lstArrGInd : list
        List of indices of contact matrices for each time step.
    lstArrG : list
        List of contact matrices
    path : str, default=None
        Export path to write the whole data to

    Returns
    -------
    np.ndarray
        SEIR x Groups x Time x Simulation Array

    """
    # calculate N
    numPeople = np.sum(arrData0[0])

    # get the number of steps
    numSteps = lstArrGInd.shape[-1]

    # S E I R along axis=0, groups along axis 1, step, scenarios
    arrData = np.zeros(
        (*arrData0.shape[:2], numSteps, numScenarios), dtype=np.int64
    )

    # set the initial values
    arrData[..., 0, :] = arrData0[..., np.newaxis]

    # total group size
    arrGroupSize = np.sum(arrData[:, :, 0, :], axis=0)

    for ss in range(1, numSteps):

        # percentage of infectious persons per compartment
        arrPercInf = arrData[2, :, ss - 1, :].astype("float") / arrGroupSize

        # percentage of contacts with infectious person
        arrL = np.einsum("ab,b...->ab...", lstArrG[lstArrGInd[ss]], arrPercInf)

        # probability to have at least one infectious contact
        arrP = 1 - np.exp(np.sum(np.log(1 - arrL), axis=1))

        # new latent variables
        arrNewLatent = np.random.binomial(arrData[0, :, ss - 1], arrP,).astype(
            "int64"
        )

        # S <- S - newLat
        arrData[0, :, ss] = arrData[0, :, ss - 1] - arrNewLatent

        arrNewInfectious = np.random.binomial(
            arrData[1, :, ss - 1], numProbEtoI
        )

        arrNewRecovered = np.random.binomial(
            arrData[2, :, ss - 1], numProbItoR
        )

        arrData[2, :, ss] = (
            arrData[2, :, ss - 1] + arrNewInfectious - arrNewRecovered
        )

        arrData[1, :, ss] = (
            arrData[1, :, ss - 1] + arrNewLatent - arrNewInfectious
        )

        arrData[3, :, ss] = arrData[3, :, ss - 1] + arrNewRecovered

    # save the data and the input parameters
    if path is not None:
        np.savez(
            path,
            arrData=arrData,
            numProbEtoI=numProbEtoI,
            numProbItoR=numProbItoR,
            lstArrGInd=lstArrGInd,
            lstArrG=lstArrG,
        )
    return arrData


def deterministic(
    tplT: tuple,
    arrData0: np.ndarray,
    numProbEtoI: float,
    numProbItoR: float,
    lstArrGInd: list,
    lstArrG: list,
    path=None,
) -> np.ndarray:
    """Deterministic Simulation of a group-based SEIR Model

    Explanation

    Parameters
    ----------
    tplT : tuple
        tuple of lover and upper integration bounds for the ODE
    arrData0 : np.ndarray
        Initial values
    numProbEtoI : float
        Probability for an individual to transition from latent
        to infectious state.
    numProbItoR : float
        Probability for an individual to transition from infectious
        to recovered state.
    lstArrGInd : list
        List of indices of contact matrices for each time step.
    lstArrG : list
        List of contact matrices
    path : str, default=None
        Export path to write the whole data to

    Returns
    -------
    np.ndarray
        SEIR x Groups x Time Array

    """

    # calculate N
    numPeople = np.sum(arrData0[0])

    # get the number of steps
    numSteps = lstArrGInd.shape[-1]

    def rhs(p, x) -> np.ndarray:
        return [
            -p * x[0] * x[2] / float(numPeople),
            p * x[0] * x[2] / float(numPeople) - x[1] * numProbEtoI,
            x[1] * numProbEtoI - x[2] * numProbItoR,
            x[2] * numProbItoR,
        ]

    arrData = np.zeros((4, int(numSteps)))
    arrData[:, 0] = arrData0[:, 0]

    for ss in range(1, int(numSteps)):
        arrData[:, ss] = arrData[:, ss - 1] + rhs(
            lstArrG[lstArrGInd[ss]], arrData[:, ss - 1]
        )

    # save the data and the input parameters
    if path is not None:
        np.savez(
            path,
            arrData=arrData,
            numProbEtoI=numProbEtoI,
            numProbItoR=numProbItoR,
            lstArrGInd=lstArrGInd,
            lstArrG=lstArrG,
        )
    return arrData
