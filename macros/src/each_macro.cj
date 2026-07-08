macro package ecsmacros

import std.ast.*
import std.collection.ArrayList

func splitCommas(ts: Tokens): ArrayList<Tokens> {
    let out = ArrayList<Tokens>()
    var cur = Tokens()
    for (t in ts) {
        if (t.kind == COMMA) {
            out.add(cur)
            cur = Tokens()
        } else if (t.kind != NL) {
            cur = cur + t
        }
    }
    out.add(cur)
    out
}

public macro Each1(attrs: Tokens, input: Tokens): Tokens {
    let parts = splitCommas(attrs)
    if (parts.size != 3) {
        diagReport(DiagReportLevel.ERROR, attrs, "`@Each1` expects attrs [ComponentType, denseIdxName, entityIdName]",
            "example: @Each1[Pos, pi, eid](...)")
        return input
    }
    let tyA = parts[0]
    let aIdx = parts[1]
    let eid = parts[2]
    quote(
        if (true) {
            let __ea_count = $(tyA).denseSize()
            let __ea_entities = $(tyA).rawEntities()
            var __ea_i: Int64 = 0
            while (__ea_i < __ea_count) {
                let $(eid) = __ea_entities[__ea_i]
                let $(aIdx) = __ea_i
                $(input)
                __ea_i += 1
            }
        }
    )
}

public macro Each2(attrs: Tokens, input: Tokens): Tokens {
    let parts = splitCommas(attrs)
    if (parts.size != 5) {
        diagReport(DiagReportLevel.ERROR, attrs, "`@Each2` expects attrs [TypeA, idxA, TypeB, idxB, entityIdName]",
            "example: @Each2[Pos, pi, Vel, vi, eid](...)")
        return input
    }
    let tyA = parts[0]
    let aIdx = parts[1]
    let tyB = parts[2]
    let bIdx = parts[3]
    let eid = parts[4]
    quote(
        if (true) {
            let __ea_countA = $(tyA).denseSize()
            let __ea_countB = $(tyB).denseSize()
            if (__ea_countA <= __ea_countB) {
                let __ea_entitiesA = $(tyA).rawEntities()
                let __ea_entitiesB = $(tyB).rawEntities()
                let __ea_sparseB = $(tyB).rawSparse()
                let __ea_sparseLenB = __ea_sparseB.size
                var __ea_i: Int64 = 0
                while (__ea_i < __ea_countA) {
                    let $(eid) = __ea_entitiesA[__ea_i]
                    let $(aIdx) = __ea_i
                    let $(bIdx) = if (__ea_entitiesB[__ea_i] == $(eid)) {
                        __ea_i
                    } else if ($(eid) < __ea_sparseLenB) {
                        __ea_sparseB[$(eid)]
                    } else {
                        -1
                    }
                    if ($(bIdx) >= 0) {
                        $(input)
                    }
                    __ea_i += 1
                }
            } else {
                let __ea_entitiesA = $(tyA).rawEntities()
                let __ea_entitiesB = $(tyB).rawEntities()
                let __ea_sparseA = $(tyA).rawSparse()
                let __ea_sparseLenA = __ea_sparseA.size
                var __ea_i: Int64 = 0
                while (__ea_i < __ea_countB) {
                    let $(eid) = __ea_entitiesB[__ea_i]
                    let $(bIdx) = __ea_i
                    let $(aIdx) = if (__ea_entitiesA[__ea_i] == $(eid)) {
                        __ea_i
                    } else if ($(eid) < __ea_sparseLenA) {
                        __ea_sparseA[$(eid)]
                    } else {
                        -1
                    }
                    if ($(aIdx) >= 0) {
                        $(input)
                    }
                    __ea_i += 1
                }
            }
        }
    )
}

public macro EachG2(attrs: Tokens, input: Tokens): Tokens {
    let parts = splitCommas(attrs)
    if (parts.size != 6) {
        diagReport(DiagReportLevel.ERROR, attrs,
            "`@EachG2` expects attrs [TypeA, idxA, TypeB, idxB, entityIdName, groupVar]",
            "example: @EachG2[Pos, pi, Vel, vi, eid, posVelGroup](...)")
        return input
    }
    let tyA = parts[0]
    let aIdx = parts[1]
    let bIdx = parts[3]
    let eid = parts[4]
    let grp = parts[5]
    quote(
        if (true) {
            let __ea_count = $(grp).size()
            var __ea_i: Int64 = 0
            while (__ea_i < __ea_count) {
                let $(eid) = $(tyA).denseEntityAt(__ea_i)
                let $(aIdx) = __ea_i
                let $(bIdx) = __ea_i
                $(input)
                __ea_i += 1
            }
        }
    )
}

public macro EachG3(attrs: Tokens, input: Tokens): Tokens {
    let parts = splitCommas(attrs)
    if (parts.size != 8) {
        diagReport(DiagReportLevel.ERROR, attrs,
            "`@EachG3` expects attrs [TypeA, idxA, TypeB, idxB, TypeC, idxC, entityIdName, groupVar]",
            "example: @EachG3[H5, hi, A5, ai, D5, di, eid, dmgGroup](...)")
        return input
    }
    let tyA = parts[0]
    let aIdx = parts[1]
    let bIdx = parts[3]
    let cIdx = parts[5]
    let eid = parts[6]
    let grp = parts[7]
    quote(
        if (true) {
            let __ea_count = $(grp).size()
            var __ea_i: Int64 = 0
            while (__ea_i < __ea_count) {
                let $(eid) = $(tyA).denseEntityAt(__ea_i)
                let $(aIdx) = __ea_i
                let $(bIdx) = __ea_i
                let $(cIdx) = __ea_i
                $(input)
                __ea_i += 1
            }
        }
    )
}

public macro Each3(attrs: Tokens, input: Tokens): Tokens {
    let parts = splitCommas(attrs)
    if (parts.size != 7) {
        diagReport(DiagReportLevel.ERROR, attrs,
            "`@Each3` expects attrs [TypeA, idxA, TypeB, idxB, TypeC, idxC, entityIdName]",
            "example: @Each3[H5, hi, A5, ai, D5, di, eid](...)")
        return input
    }
    let tyA = parts[0]
    let aIdx = parts[1]
    let tyB = parts[2]
    let bIdx = parts[3]
    let tyC = parts[4]
    let cIdx = parts[5]
    let eid = parts[6]
    quote(
        if (true) {
            let __ea_countA = $(tyA).denseSize()
            let __ea_countB = $(tyB).denseSize()
            let __ea_countC = $(tyC).denseSize()
            let __ea_entitiesA = $(tyA).rawEntities()
            let __ea_entitiesB = $(tyB).rawEntities()
            let __ea_entitiesC = $(tyC).rawEntities()
            if (__ea_countA <= __ea_countB && __ea_countA <= __ea_countC) {
                let __ea_sparseB = $(tyB).rawSparse()
                let __ea_sparseLenB = __ea_sparseB.size
                let __ea_sparseC = $(tyC).rawSparse()
                let __ea_sparseLenC = __ea_sparseC.size
                var __ea_i: Int64 = 0
                while (__ea_i < __ea_countA) {
                    let $(eid) = __ea_entitiesA[__ea_i]
                    let $(aIdx) = __ea_i
                    let $(bIdx) = if (__ea_entitiesB[__ea_i] == $(eid)) {
                        __ea_i
                    } else if ($(eid) < __ea_sparseLenB) {
                        __ea_sparseB[$(eid)]
                    } else {
                        -1
                    }
                    if ($(bIdx) >= 0) {
                        let $(cIdx) = if (__ea_entitiesC[__ea_i] == $(eid)) {
                            __ea_i
                        } else if ($(eid) < __ea_sparseLenC) {
                            __ea_sparseC[$(eid)]
                        } else {
                            -1
                        }
                        if ($(cIdx) >= 0) {
                            $(input)
                        }
                    }
                    __ea_i += 1
                }
            } else if (__ea_countB <= __ea_countC) {
                let __ea_sparseA = $(tyA).rawSparse()
                let __ea_sparseLenA = __ea_sparseA.size
                let __ea_sparseC = $(tyC).rawSparse()
                let __ea_sparseLenC = __ea_sparseC.size
                var __ea_i: Int64 = 0
                while (__ea_i < __ea_countB) {
                    let $(eid) = __ea_entitiesB[__ea_i]
                    let $(bIdx) = __ea_i
                    let $(aIdx) = if (__ea_entitiesA[__ea_i] == $(eid)) {
                        __ea_i
                    } else if ($(eid) < __ea_sparseLenA) {
                        __ea_sparseA[$(eid)]
                    } else {
                        -1
                    }
                    if ($(aIdx) >= 0) {
                        let $(cIdx) = if (__ea_entitiesC[__ea_i] == $(eid)) {
                            __ea_i
                        } else if ($(eid) < __ea_sparseLenC) {
                            __ea_sparseC[$(eid)]
                        } else {
                            -1
                        }
                        if ($(cIdx) >= 0) {
                            $(input)
                        }
                    }
                    __ea_i += 1
                }
            } else {
                let __ea_sparseA = $(tyA).rawSparse()
                let __ea_sparseLenA = __ea_sparseA.size
                let __ea_sparseB = $(tyB).rawSparse()
                let __ea_sparseLenB = __ea_sparseB.size
                var __ea_i: Int64 = 0
                while (__ea_i < __ea_countC) {
                    let $(eid) = __ea_entitiesC[__ea_i]
                    let $(cIdx) = __ea_i
                    let $(aIdx) = if (__ea_entitiesA[__ea_i] == $(eid)) {
                        __ea_i
                    } else if ($(eid) < __ea_sparseLenA) {
                        __ea_sparseA[$(eid)]
                    } else {
                        -1
                    }
                    if ($(aIdx) >= 0) {
                        let $(bIdx) = if (__ea_entitiesB[__ea_i] == $(eid)) {
                            __ea_i
                        } else if ($(eid) < __ea_sparseLenB) {
                            __ea_sparseB[$(eid)]
                        } else {
                            -1
                        }
                        if ($(bIdx) >= 0) {
                            $(input)
                        }
                    }
                    __ea_i += 1
                }
            }
        }
    )
}
