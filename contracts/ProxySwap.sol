// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
		external
		payable
		returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(
		uint256 amountIn,
		address[] calldata path
	) external view returns (uint256[] memory amounts);

	function getAmountsIn(
		uint256 amountOut,
		address[] calldata path
	) external view returns (uint256[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

pragma solidity >=0.5.0;

interface IERC20 {
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint8);

	function totalSupply() external view returns (uint256);

	function balanceOf(address owner) external view returns (uint256);

	function allowance(
		address owner,
		address spender
	) external view returns (uint256);

	function approve(address spender, uint256 value) external returns (bool);

	function transfer(address to, uint256 value) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);
}

contract PancakeSwapProxy {
	IPancakeRouter02 public router;
	address public owner;

	uint256 approveInfinity =
		115792089237316195423570985008687907853269984665640564039457584007913129639935;

	constructor(address _router) {
		router = IPancakeRouter02(_router);
		owner = msg.sender;
	}

	function approve(IERC20 token) external {
		token.approve(address(router), approveInfinity);
	}

	function withdrawAll(IERC20 token) external {
		uint256 balance = token.balanceOf(address(this));

		token.transfer(msg.sender, balance);
	}

	function withdrawBalance() external {
		uint256 balance = address(this).balance;

		payable(msg.sender).transfer(balance);
	}

	function withdraw(IERC20 token, uint256 amount) external {
		token.transfer(msg.sender, amount);
	}

	function safuSell(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path
	) external {
		require(msg.sender == owner, "Only owner can call this function");

		// Swap tokens
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amountIn,
			amountOutMin,
			path,
			address(this),
			block.timestamp
		);
	}

	function safuBuy(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path
	) external {
		require(msg.sender == owner, "Only owner can call this function");

		// Swap tokens
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amountIn,
			amountOutMin,
			path,
			address(this),
			block.timestamp
		);

		IERC20 token = IERC20(path[path.length - 1]);

		token.approve(address(router), approveInfinity);
	}

	function transferOwnership(address newOwner) external {
		require(msg.sender == owner, "Only owner can call this function");
		owner = newOwner;
	}

	function setRouter(address _router) external {
		require(msg.sender == owner, "Only owner can call this function");
		router = IPancakeRouter02(_router);
	}

	receive() external payable {}

	fallback() external payable {}
}
