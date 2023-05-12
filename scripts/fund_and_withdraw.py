from brownie import FundMe
from scripts.helpful_scripts import get_account


# Executes the fund function based on the FundMe contract
def fund():
    # Get the most recent contract created form the FundMe smart contract
    fund_me = FundMe[-1]

    # Get account based on the network we're deploying
    account = get_account()
    print("account: ", account, "\nFund Me: ", fund_me)

    # Get the entrance fee
    entrance_fee = fund_me.getEntranceFee()
    print(f"The current entry fee is {entrance_fee}")
    print("Funding ...")

    # Fund the contract
    fund_me.fund({"from": account, "value": entrance_fee})


# Executes the withdraw function based on the FundMe contract
def withdraw():
    # Get the most recent contract
    fund_me = FundMe[-1]

    # Get account based on the network we're deploying
    account = get_account()

    # Withdraw the funds from the contract
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
