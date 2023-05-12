from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest


# Test if it's possible to fund and withdraw funds from the contract
def test_can_fund_and_withdraw():
    # get account from the chosen network
    account = get_account()

    # deploy the FundMe contract to the chosen network
    fund_me = deploy_fund_me()

    # Get the entrance fee
    entrance_fee = fund_me.getEntranceFee() + 100

    # Create a fund transaction
    tx = fund_me.fund({"from": account, "value": entrance_fee})
    tx.wait(1)

    # Verify if the amount funded from the given address
    # is as expected
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee

    # Create an withdraw transaction
    tx2 = fund_me.withdraw({"from": account})
    tx2.wait(1)

    # Verify if the amount funded from the given address
    # is 0 as expected
    assert fund_me.addressToAmountFunded(account.address) == 0


# Test if only the owner can withdraw funds from the contract
def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")

    # Deploy the FundMe contract to the chosen network
    fund_me = deploy_fund_me()

    # Create a bad actor wallet
    bad_actor = accounts.add()

    # Test if the result from the bad actor trying to withdraw funds
    # is as expected.
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdraw({"from": bad_actor})
