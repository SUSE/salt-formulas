dhcpd
=====

Formula to install, configure and start dhcpd.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``dhcpd``
---------

Install and turn on dhcpd.

.. note::
    
    To have more pythonic variables the dashes ('-') in their names
    are replaced with underscores ('_') so 'dynamic-bootp' becomes
    'dynamic_bootp' in pillar[dhcpd].

``dhcpd.config``
----------------

Manage configuration for dhcpd.
See ``pillar.example`` for pillar-data for a sample configuration.

Note
====
Repackaged from https://github.com/saltstack-formulas/dhcpd-formula