// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IDiamondLoupe.sol";
import "../lib/LibDiamond.sol";

/**
 * @title Diamond Loupe Facet
 */
contract DiamondLoupeFacet is IDiamondLoupe {
    function facets() external override view returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numFacets = ds.facetAddresses.length;
        facets_ = new Facet[](numFacets);
        for (uint256 i; i < numFacets; i++) {
            address facetAddress = ds.facetAddresses[i];
            facets_[i].facetAddress = facetAddress;
            facets_[i].functionSelectors = ds.facetFunctionSelectors[facetAddress].functionSelectors;
        }
    }

    function facetFunctionSelectors(address _facet) external override view returns (bytes4[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.facetFunctionSelectors[_facet].functionSelectors;
    }

    function facetAddresses() external override view returns (address[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.facetAddresses;
    }

    function facetAddress(bytes4 _functionSelector) external override view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.selectorToFacetAndPosition[_functionSelector].facetAddress;
    }
}