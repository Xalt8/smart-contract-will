import pytest
from brownie import Wei, accounts, Inheritance



@pytest.fixture
def inheritance():
    inheritance = Inheritance.deploy({'from': accounts[0], 'value': '2 ether'})
    return inheritance


def test_constructor(inheritance):
    assert inheritance.heirloom() == Wei('2 ether'), "Heirloom should have 2 Eth in it"
    assert inheritance.owner() == accounts[0].address, "Not owner"


def test_withdraw_success(inheritance):
    ''' Checks to see if the heirloom amount is deducted and the owner balance is credited'''
    pre_withdraw_heirloom_balance = inheritance.heirloom()
    pre_withdraw_owner_balance = accounts[0].balance()
    inheritance.withdraw(Wei('1 ether'))
    assert inheritance.heirloom() == pre_withdraw_heirloom_balance - Wei('1 ether')      
    assert accounts[0].balance() == pre_withdraw_owner_balance + Wei('1 ether')  


def test_add_remove_heir(inheritance):
    assert inheritance.get_heir_count() == 0, "There should be no heirs"
    inheritance.add_heir(accounts[1].address)
    inheritance.add_heir(accounts[2].address)
    assert inheritance.get_heir_count() == 2, "There should be 1 heir"
    assert inheritance.check_heir(accounts[1].address), "This heir should checkout"
    assert inheritance.check_heir(accounts[2].address), "This heir should checkout"
    inheritance.delete_all_heirs()
    assert not inheritance.check_heir(accounts[1].address), "This heir should not be here"
    assert not inheritance.check_heir(accounts[2].address), "This heir should not be here"
    

    

